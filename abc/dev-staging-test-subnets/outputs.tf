#
# Output the information required to test the
# environment created in main.tf
#
# - Username for bastion host (same for all instances)
# - Password for bastion host (same for all instances)
# - Public IP address for bastion host
#
# Also output the private IP addresses for each instance:
#
# - Private IP for development instance
# - Private IP for staging instance
# - Private IP for production instance
# - Private IP for management instance
#
# Testing the environment:
# 
# - Log into the bastion host. From there, use SSH to log into
# any of (dev, staging, prod) and use ping to confirm security group
# rules are restricting traffic flow like so:
# 
# development -> staging -> production

output "username" {
  description = "Username for instance login (all instances)"
  value       = "root"
}

output "password" {
  description = "Password for instance login (all instances)"
  value       = "${var.password}"
}

output "management_ip" {
  description = "Public IP address of our new Windows 2016 instance"
  value       = "${alicloud_instance.tf_example_management.public_ip}"
}

output "dev_private_ip" {
    description = "Private IP of development instance"
    value = "${alicloud_instance.tf_example_dev.private_ip}"
}

output "staging_private_ip" {
    description = "Private IP of staging instance"
    value = "${alicloud_instance.tf_example_staging.private_ip}"
}

output "prod_private_ip" {
    description = "Private IP of production instance"
    value = "${alicloud_instance.tf_example_production.private_ip}"
}

output "management_private_ip" {
    description = "Private IP of management instance"
    value = "${alicloud_instance.tf_example_management.private_ip}"
}