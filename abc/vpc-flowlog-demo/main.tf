# Create demo environment with VPN Gateway, NAT Gateway, several ECS instances 
# for testing VPC FLowLog functionality
#
# Author: Jeremy Pedersen
# Creation Date: 2019-12-06
# Last Updated: 2019-12-06
#
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.access_key_secret}"
  region     = "${var.region}"
}

data "alicloud_zones" "abc_zones" {  }

# Get a list of ECS instances with 2 CPU cores and 4GB RAM
data "alicloud_instance_types" "cores2mem8g" {
  instance_type_family = "ecs.g6"
  cpu_core_count = 2
  memory_size = 8
}

# Create VPC group
resource "alicloud_vpc" "flowlog-example-vpc" {
  name       = "flowlog-example-vpc"
  cidr_block = "192.168.0.0/16"
}

# Create a vSwitch
resource "alicloud_vswitch" "flowlog-example-vswitch-a" {
  name              = "flowlog-example-vswitch-a"
  vpc_id            = "${alicloud_vpc.flowlog-example-vpc.id}"
  cidr_block        = "192.168.0.0/24"
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

# Create a vSwitch
resource "alicloud_vswitch" "flowlog-example-vswitch-b" {
  name              = "flowlog-example-vswitch-b"
  vpc_id            = "${alicloud_vpc.flowlog-example-vpc.id}"
  cidr_block        = "192.168.1.0/24"
  availability_zone = "${data.alicloud_zones.abc_zones.zones.1.id}"
}

# Create security group for ECS instances (allows 22 inbound)
resource "alicloud_security_group" "flowlog-example-sg" {
  name        = "flowlog-example-sg"
  vpc_id      = "${alicloud_vpc.flowlog-example-vpc.id}"
  description = "Webserver security group"
}

# Create inbound rule for SSH traffic (port 22 TCP)

resource "alicloud_security_group_rule" "ssh-in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = "${alicloud_security_group.flowlog-example-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "icmp-in" {
  type              = "ingress"
  ip_protocol       = "icmp"
  policy            = "accept"
  port_range        = "-1/-1"
  security_group_id = "${alicloud_security_group.flowlog-example-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

# Create keypair for connecting to ECS instances
resource "alicloud_key_pair" "flowlog-example-ssh-key" {
  key_name = "flowlog-example-ssh-key"
  key_file = "flowlog-example-ssh-key.pem"
}

#
# Create external network connection interfaces for tesitng purposes
#
# 1 - VPN Gateway (inbound private traffic)
# 2 - NAT Gateway (outbound internet traffic)
#
resource "alicloud_vpn_gateway" "flowlog-example-vpn-gateway" {
  name                 = "flowlog-example-vpn-gateway"
  vpc_id               = "${alicloud_vpc.flowlog-example-vpc.id}"
  bandwidth            = "10"
  enable_ssl           = true
  instance_charge_type = "PostPaid" # WARNING: This must be changed to PrePaid when using aliyun.com
  description          = "flowlog-example-vpn-gateway"
}

# VPN Configuration (VPN Server, Client Cert)
resource "alicloud_ssl_vpn_server" "flowlog-ssl-vpn-server" {
  name = "flowlog-ssl-vpn-server"
  vpn_gateway_id = "${alicloud_vpn_gateway.flowlog-example-vpn-gateway.id}"
  client_ip_pool = "10.0.0.0/16"
  local_subnet = "${alicloud_vpc.flowlog-example-vpc.cidr_block}"
}

resource "alicloud_ssl_vpn_client_cert" "flowlog-ssl-vpn-client-cert" {
  name = "flowlog-ssl-vpn-client-cert"
  ssl_vpn_server_id = "${alicloud_ssl_vpn_server.flowlog-ssl-vpn-server.id}"
}

resource "alicloud_nat_gateway" "flowlog-example-nat-gateway" {
  vpc_id = "${alicloud_vpc.flowlog-example-vpc.id}"
  specification = "Small"
  name   = "flowlog-example-nat-gateway"
}

# EIP and EIP binding for NAT Gateway
resource "alicloud_eip" "nat-gateway-eip" {
  name = "nat-gateway-eip"
}

resource "alicloud_eip_association" "nat-gateway-eip-assoc" {
  allocation_id = "${alicloud_eip.nat-gateway-eip.id}"
  instance_id   = "${alicloud_nat_gateway.flowlog-example-nat-gateway.id}"
}

# 
# Create 3 different ECS instances for testing purposes
#
# 1 - Internal IP, vSwitch 0
# 2 - Internal IP + external IP, vSwitch 0
# 3 - Internal IP, vSwitch 1
#
resource "alicloud_instance" "flowlog-example-ecs-1-vsw-a" {
  instance_name = "flowlog-example-ecs-1-vsw-a"

  image_id = "${var.abc_image_id}"

  instance_type        = "${data.alicloud_instance_types.cores2mem8g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.flowlog-example-sg.id}"]
  vswitch_id           = "${alicloud_vswitch.flowlog-example-vswitch-a.id}"

  key_name = "${alicloud_key_pair.flowlog-example-ssh-key.key_name}"

  internet_max_bandwidth_out = 0 # Make sure instance is NOT granted a public IP
}

resource "alicloud_instance" "flowlog-example-ecs-2-vsw-a" {
  instance_name = "flowlog-example-ecs-2-vsw-a"

  image_id = "${var.abc_image_id}"

  instance_type        = "${data.alicloud_instance_types.cores2mem8g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.flowlog-example-sg.id}"]
  vswitch_id           = "${alicloud_vswitch.flowlog-example-vswitch-a.id}"

  key_name = "${alicloud_key_pair.flowlog-example-ssh-key.key_name}"

  internet_max_bandwidth_out = 10 # Make sure instance IS granted a public IP
}

resource "alicloud_instance" "flowlog-example-ecs-3-vsw-b" {
  instance_name = "flowlog-example-ecs-3-vsw-b"

  image_id = "${var.abc_image_id}"

  instance_type        = "${data.alicloud_instance_types.cores2mem8g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.flowlog-example-sg.id}"]
  vswitch_id           = "${alicloud_vswitch.flowlog-example-vswitch-b.id}"

  key_name = "${alicloud_key_pair.flowlog-example-ssh-key.key_name}"

  internet_max_bandwidth_out = 0 # Make sure instance is NOT granted a public IP
}

#
# Log Store Project and Associated Log Stores
#
# N Logstores are created:
# 1 - vpc-logstore (for VPC-level FlowLog)
# 2 - vswitch-logstore (for vSwitch-level FlowLog)
# 3 - 
#
resource "alicloud_log_project" "flowlog-demo-sls-project" {
  name        = "flowlog-demo-sls-project"
  description = "Demo project for testing VPC FlowLog functionality"
}
resource "alicloud_log_store" "vpc-logstore" {
  project               = "${alicloud_log_project.flowlog-demo-sls-project.name}"
  name                  = "vpc-logstore"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

resource "alicloud_log_store" "vswitch-a-logstore" {
  project               = "${alicloud_log_project.flowlog-demo-sls-project.name}"
  name                  = "vswitch-a-logstore"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

resource "alicloud_log_store" "vswitch-b-logstore" {
  project               = "${alicloud_log_project.flowlog-demo-sls-project.name}"
  name                  = "vswitch-b-logstore"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

resource "alicloud_log_store" "ecs-1-logstore" {
  project               = "${alicloud_log_project.flowlog-demo-sls-project.name}"
  name                  = "ecs-1-logstore"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

resource "alicloud_log_store" "ecs-2-logstore" {
  project               = "${alicloud_log_project.flowlog-demo-sls-project.name}"
  name                  = "ecs-2-logstore"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

resource "alicloud_log_store" "ecs-3-logstore" {
  project               = "${alicloud_log_project.flowlog-demo-sls-project.name}"
  name                  = "ecs-3-logstore"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}
