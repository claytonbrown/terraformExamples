#
# This script sets up the infrasctructure required for running a simple CI/CD pipeline on 
# Alibaba Cloud. Subsequent helper scripts configure and install software on top of the
# infrastructure created here
#
# Author: Jeremy Pedersen
# Creation Date: 2019/06/27
# Last Update: 2019/06/28

provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.access_key_secret}"
  region     = "${var.region}"
}

# Get a list of availability zones
data "alicloud_zones" "abc_zones" {}

# Get a list of mid-range instnace types we can use
# in the selected region and zone
data "alicloud_instance_types" "2c4g" {
  memory_size = 4
  cpu_core_count = 2
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

###
# VPC and VSwitch Config
### 

resource "alicloud_vpc" "cicd-demo-vpc" {
  name       = "cicd-demo-vpc"
  cidr_block = "192.168.0.0/16"
}

resource "alicloud_vswitch" "cicd-demo-vswitch" {
  name              = "cicd-demo-vswitch"
  vpc_id            = "${alicloud_vpc.cicd-demo-vpc.id}"
  cidr_block        = "192.168.0.0/24"
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

###
# Security Group Config
###
resource "alicloud_security_group" "cicd-demo-sg" {
  name        = "cicd-demo-sg"
  vpc_id      = "${alicloud_vpc.cicd-demo-vpc.id}"
  description = "Web tier security group"
}

# Open access for ICMP (ping), SSH, HTTP, and HTTPS from the internet
resource "alicloud_security_group_rule" "http_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "80/80"
  security_group_id = "${alicloud_security_group.cicd-demo-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "https_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "443/443"
  security_group_id = "${alicloud_security_group.cicd-demo-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "ssh_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = "${alicloud_security_group.cicd-demo-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  policy            = "accept"
  port_range        = "-1/-1"
  security_group_id = "${alicloud_security_group.cicd-demo-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

###
# OSS Bucket Config
###

# Generate a random string to ensure a unique bucket name
resource "random_pet" "bucket-name" {
  length = 3
  prefix = "gitlab-oss-bucket"
}

resource "alicloud_oss_bucket" "gitlab-oss-bucket" {
  bucket = "${random_pet.bucket-name.id}"
  acl = "private" 
}

###
# SSH Key Config
###

# SSH key pair for instance login
resource "alicloud_key_pair" "speed-test-key" {
  key_name = "${var.ssh_key_name}"
  key_file = "${var.ssh_key_name}.pem"
}

###
# ECS Config
###

# Create GitLab instance
resource "alicloud_instance" "cicd-demo-gitlab-ecs" {
  instance_name = "cicd-demo-gitlab-ecs"

  image_id = "ubuntu_18_04_64_20G_alibase_20190624.vhd"

  instance_type        = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.cicd-demo-sg.id}"]
  vswitch_id           = "${alicloud_vswitch.cicd-demo-vswitch.id}"

  # SSH Key for instance login
  key_name = "${var.ssh_key_name}"

  # Make sure no public IP is assigned (we will bind an EIP instead)
  internet_max_bandwidth_out = 0
}

resource "alicloud_instance" "cicd-demo-sonar-ecs" {
  instance_name = "cicd-demo-sonar-ecs"

  image_id = "ubuntu_18_04_64_20G_alibase_20190624.vhd"

  instance_type        = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.cicd-demo-sg.id}"]
  vswitch_id           = "${alicloud_vswitch.cicd-demo-vswitch.id}"

  # SSH Key for instance login
  key_name = "${var.ssh_key_name}"

  # Make sure no public IP is assigned (we will bind an EIP instead)
  internet_max_bandwidth_out = 0
}

###
# EIP Config
###

# EIP for GitLab instance (5 Mbps bandwidth by default)
resource "alicloud_eip" "gitlab-eip" {
  name = "gitlab-eip"
}

resource "alicloud_eip_association" "gitlab-eip-assoc" {
  allocation_id = "${alicloud_eip.gitlab-eip.id}"
  instance_id = "${alicloud_instance.cicd-demo-gitlab-ecs.id}"
}

# EIP for SonarQube instance (5 Mbps bandwidth by default)
resource "alicloud_eip" "sonar-eip" {
  name = "sonar-eip"
}

resource "alicloud_eip_association" "sonar-eip-assoc" {
  allocation_id = "${alicloud_eip.sonar-eip.id}"
  instance_id = "${alicloud_instance.cicd-demo-sonar-ecs.id}"
}

###
# DNS Config
###

# GitLab DNS Record
resource "alicloud_dns_record" "gitlab-dns" {
  name = "${var.domain}"
  host_record = "gitlab"
  type = "A"
  value = "${alicloud_eip.gitlab-eip.ip_address}"
}

# SonarQube DNS Record
resource "alicloud_dns_record" "sonar-dns" {
  name = "${var.domain}"
  host_record = "sonar"
  type = "A"
  value = "${alicloud_eip.gitlab-eip.ip_address}"
}

###
# DirectMail DNS Records
###

# Ownership Verification
resource "alicloud_dns_record" "directmail-ownership" {
  name = "${var.domain}"
  host_record = "${var.dm_ownership_host_record}"
  type = "TXT"
  value = "${var.dm_ownership_record_value}"
}

# SPF Verification
resource "alicloud_dns_record" "directmail-spf" {
  name = "${var.domain}"
  host_record = "${var.dm_spf_host_record}"
  type = "TXT"
  value = "${var.dm_spf_record_value}"
}

# MX Verification
resource "alicloud_dns_record" "directmail-mx" {
  name = "${var.domain}"
  host_record = "${var.dm_mx_host_record}"
  type = "MX"
  value = "${var.dm_mx_record_value}"
}

# CNAME Verification
resource "alicloud_dns_record" "directmail-cname" {
  name = "${var.domain}"
  host_record = "${var.dm_cname_host_record}"
  type = "CNAME"
  value = "${var.dm_cname_record_value}"
}

###
# RAM Account Config
###

# Create a RAM account (and credentials) for full read/write access to OSS
# (this will be used by GitLab for configuration backups)

