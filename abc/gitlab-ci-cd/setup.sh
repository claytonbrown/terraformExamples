#!/bin/bash

# Setup GitLab and SonarQube infrastructure
echo "Running terraform..."
terraform apply -auto-approve

# Save SSH key name to an environment variable
export SSH_KEY=$(terraform output ssh_key_name)

# Restrict SSH key permissions
chmod 600 $SSH_KEY

# Create hosts file for Ansible
echo "Creating hosts file..."
echo "[gitlab]" > ansible/hosts
echo $(terraform output gitlab_url) >> ansible/hosts
echo "[sonar]" >> ansible/hosts
echo $(terraform output sonar_url) >> ansible/hosts

# Create Ansible variables file for gitlab variables
echo "Creating gitlab variables file for Ansible"
echo "---" > ansible/group_vars/gitlab

# Set gitlab OSS bucket vars
echo "gitlab_hostname: $(terraform output gitlab_url)" >> ansible/group_vars/gitlab
echo "gitlab_bucket_name: $(terraform output gitlab_bucket_name)" >> ansible/group_vars/gitlab
echo "gitlab_bucket_endpoint: $(terraform output gitlab_bucket_endpoint)" >> ansible/group_vars/gitlab
echo "gitlab_bucket_ak: $(cat oss-fullaccess.ak | grep "AccessKeyId" | awk '{print $2}' | sed "s/\"//g")" >> ansible/group_vars/gitlab
echo "gitlab_bucket_ak_secret: $(cat oss-fullaccess.ak | grep "AccessKeySecret" | awk '{print $2}' | sed "s/,//g" | sed "s/\"//g")" >> ansible/group_vars/gitlab

# Set additional vars needed in gitlab.rb
echo "directmail_email: $(terraform output directmail_email)" >> ansible/group_vars/gitlab
echo "directmail_password: $(terraform output directmail_password)" >> ansible/group_vars/gitlab
echo "directmail_url: $(terraform output directmail_url)" >> ansible/group_vars/gitlab
echo "email_address: $(terraform output email_address)" >> ansible/group_vars/gitlab
echo "directmail_smtp_address: $(terraform output directmail_smtp_address)" >> ansible/group_vars/gitlab

# Create Ansible variable file for SonarQube variables
echo "Creating SonarQube variables file for Ansible"
echo "---" > ansible/group_vars/sonar

# Set SonarQube variables
echo "sonarqube_username: $(terraform output sonarqube_db_username)" >> ansible/group_vars/sonar
echo "sonarqube_password: $(terraform output sonarqube_db_password)" >> ansible/group_vars/sonar
echo "sonarqube_domain: $(terraform output sonarqube_domain)" >> ansible/group_vars/sonar
echo "sonarqube_db_connection_string: $(terraform output sonarqube_db_connection)" >> ansible/group_vars/sonar
echo "email_address: $(terraform output email_address)" >> ansible/group_vars/sonar

# Wait 10 seconds before running ansible commands (give hosts time to boot)
echo "Waiting 10 seconds..."
sleep 10

# Run Ansible playbook to install and configure GitLab and SonarQube
echo "Running Ansible playbooks..."
cd ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts --key-file ../$SSH_KEY site.yml
