# Variables referenced in main.tf
# 
# Note: DO NOT SAVE sensitive information here such as Access Keys or passwords. 
# Instead, supply these as shell environment variables, use the "-var" flag to supply them 
# on the command line, or set up a 'terraform.tfvars' file and add *.tfvars to your .gitignore file
#
variable "access_key" {
    # No default, must be provided on command line or via environment variable
    description = "Alibaba Cloud Access Key ID"
}

variable "access_key_secret" {
    # No default, must be provided on command line or via environment variable
    description = "Alibaba Cloud Secret Key"
}

# Password for ECS instance login
variable "ssh_key_name" {
    description = "ECS Login Password (for root)"
    default = "cicd-demo-ssh-key"
}

# Set default region to Singapore (ap-southeast-1)
# WARNING: If you change this, be aware that it could complicate the 
# configuration of DirectMail, which is only available in the Hangzhou,
# Singapore, and Sydney regions. 
variable "region" {
    description = "Region in which to deploy resources (RDS, ECS, EIP) - set to Singapore by default"
    default = "ap-southeast-1"
}

# Registered domain name where applications will be hosted
# The script assumes the domain was PURCHASED USING ALIBABA
# CLOUD and will be CONFIGURED USING ALIBABA CLOUD DNS
variable "domain" {
    description = "The domain name where you will host your application"
}

# DNS Records for DirectMail

# TXT record from "1,Ownership Verification" section of DirectMail console
variable "dm_ownership_host_record" {
    description = "Host record from '1,Ownership Verification' section of DirectMail configuration"
}

variable "dm_ownership_record_value" {
    description = "Record value from '1,Ownership Verification' section of DirectMail configuration"
}

# TXT record from "2,PF Verification" section of DirectMail console

variable "dm_spf_host_record" {
    description = "Host record from '2,SPF Verification' section of DirectMail configuration"
}

variable "dm_spf_record_value" {
    description = "Record value from '1,SPF Verification' section of DirectMail configuration"
}

# MX record from "3,MX Record Verficiation" section of DirectMail console
variable "dm_mx_host_record" {
    description = "Host record from '3,MX Record Verification' section of DirectMail configuration"
}

variable "dm_mx_record_value" {
    description = "Record value from '3,MX Record Verification' section of DirectMail configuration"
}

# CNAME record from "4,CNAME Record Verification" section of DirectMail console
variable "dm_cname_host_record" {
    description = "Host record from '4,CNAME Record Verification' section of DirectMail configuration"
}

variable "dm_cname_record_value" {
    description = "Record value from '4,CNAME Record Verification' section of DirectMail configuration"
}