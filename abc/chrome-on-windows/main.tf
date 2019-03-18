#
# Set up a Windows Server 2016 ECS instance and install 
# Chrome using a PowerShell script
#
# Author: Jeremy Pedersen
# Date: 2019-03-12
#

# Set up the "aliyun" (Alibaba Cloud) provider
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.access_key_secret}"
  region     = "${var.region}"
}

# Determine what availability zones are available in our chosen region
data "alicloud_zones" "abc_zones" {}

# Find instances types available in the chosen region/availability zone
# with at least 8 GB of memory
data "alicloud_instance_types" "8g" {
  memory_size       = 8
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

# Create Windows Server ECS instance
resource "alicloud_instance" "tf_example" {
  instance_name = "tf_examples_windows2016"

  image_id = "win2016_64_dtc_1607_en-us_40G_alibase_20181220.vhd"

  instance_type        = "${data.alicloud_instance_types.8g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"                                       # cheapest (standard) disk type
  security_groups      = ["${alicloud_security_group.tf_example.id}"]

  vswitch_id = "${alicloud_vswitch.tf_example.id}"

  password = "${var.password}"

  # Ensure we get a public IP address by choosing a non-zero Internet bandwidth
  internet_max_bandwidth_out = 10 # 10 Mbps - plenty for a demo

  # Powershell script to install Chrome
  user_data = "${file("install_chrome.ps1")}"
}

# Set up vSwitch and VPC
resource "alicloud_vpc" "tf_example" {
  name       = "tf_examples_windows2016_vpc"
  cidr_block = "${var.cidr_block}"
}

resource "alicloud_vswitch" "tf_example" {
  vpc_id            = "${alicloud_vpc.tf_example.id}"
  cidr_block        = "${var.cidr_block}"
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

# Set up security group and security group rules
resource "alicloud_security_group" "tf_example" {
  name   = "tf_examples_windows2016"
  vpc_id = "${alicloud_vpc.tf_example.id}"
}

# Create security group rule for RDP access
resource "alicloud_security_group_rule" "tf_example_rdp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "3389/3389"
  security_group_id = "${alicloud_security_group.tf_example.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "tf_example_outbound" {
  type              = "egress"
  ip_protocol       = "all"
  port_range        = "-1/-1"
  security_group_id = "${alicloud_security_group.tf_example.id}"
  cidr_ip           = "0.0.0.0/0"
}
