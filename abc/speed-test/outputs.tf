#
# Output the information required to test the
# environment created in main.tf
#
# - Username for instance
# - Public IP address for instance
#
output "username" {
  description = "Username for instance login (all instances)"
  value       = "root"
}

output "management_ip" {
  description = "Instance public IP address"
  value       = "${alicloud_instance.speed-test-ecs.public_ip}"
}
