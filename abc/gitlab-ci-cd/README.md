# GitLab Ci/CD

## What

The scripts here create a CI/CD pipeline based on Alibaba Cloud's comprehensive [DevOps Tutorial](https://alibabacloud-howto.github.io/devops/).

The scripts here create and configure the Alibaba Cloud resources necessary to have a fully functional CI/CD pipeline that deploys a toy "Todolist" application written in Java (backend) and JavaScript (frontend - in React).

The pipeline includes sophisticated features such as:
- Automatic building and testing of application code using GitLab, Docker, and SonarQube
- Automatic deployment of dev, pre-prod, and production environments using terraform and packer
- The toy application is deployed using immutable infrastructure best practices
- Automatic warnings of build failures and code quality check failures via email (GitLab + DirectMail)

## Prerequisites

Some resources must be configured in advance by hand because automatic provisioning is not possible through either terraform or the Alibaba Cloud API. Right now, manual steps include:
- Purchasing a domain name (**must be less than 28 characters long** due to a limitation in DirectMail)
- Setting up an initial RAM account and access key for use with terraform

In addition, your local machine must have:
- Ansible 2.8 or newer
- Terraform 0.11 (**alicloud provider does not yet support 0.12**)
- The ability to run bash shellscripts

## Resources Created

Running the scripts here will create the following resources (you will be charged for these unless your Alibaba Cloud currently has applicable coupons):

- 1xECS (GitLab host)
- 1xECS (GitLab runner)
- 1xECS (SonarQube)
- 1xRDS (SonarQube PostgreSQL database)
- 1xOSS (GitLab configuration backups and SSL certificates for the deployed application)
- 1xDirectMail (GitLab and SonarQube email notifications)

And of course once you deploy the todolist application, you will end up with these additional resources:

3xSLB (todolist application load balancer)
3xECS (SSL certificate management machines for dev, pre-prod, and production environments)
6xECS (todolist application servers)
3xRDS (todolist MySQL database servers)

The numbers here account for the fact that 3 identical environments will be running, one for development, another for pre-production, and finally another for production.

## Contents of this repository

Currently, the repository holds the following files:

```
COMING SOON
```

## Why

The concept of "DevOps" is broad and encompasses a lot of different tools and ways of thinking. Cultivating a CI/CD workflow also takes time and involves solving numerous complex issues around application deployment, logging, and debugging. Having a toy environment to play with and serve as a model for future applications can help you better understand which direction you should take in adopting your own "DevOps" practices.

## How

COMING SOON

## Notes and Warnings

COMING SOON

## Architecture

COMING SOON