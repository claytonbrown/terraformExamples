# GitLab CI/CD

- Terraform Version: 0.12
- Alibaba Cloud Provider Version: 1.52
- Status: Script working as of 2019-08-07 (YYYY-MM-DD)

## What

A GitLab-based CI/CD pipeline based on Alibaba Cloud's comprehensive [DevOps Tutorial](https://alibabacloud-howto.github.io/devops/).

The scripts here create and configure the Alibaba Cloud resources necessary to have a fully functional CI/CD pipeline that deploys a toy "Todolist" application written in Java (backend) and JavaScript (frontend - in React).

The pipeline includes sophisticated features such as:
- Automatic building and testing of the sample application code using GitLab, Docker, and SonarQube
- Automatic deployment of dev, pre-prod, and production environments using terraform and packer
- The toy application is deployed using **immutable infrastructure** best practices
- Automatic warnings of build failures and code quality check failures via email (GitLab + DirectMail)

## Prerequisites

Some resources must be configured in advance by hand because automatic provisioning is not possible through either terraform or the Alibaba Cloud API. Right now, manual steps include:
1.  Purchasing a domain name (which **must be less than 28 characters long** due to a limitation in DirectMail)
2.  Setting up an initial RAM account and access key for use with terraform

In addition, your local machine must have:
- Ansible 2.8 or newer
- Terraform 0.11 (**as of writing, the alicloud terraform provider does not yet  terraform 0.12**)
- The ability to run bash shell scripts (tested on macOS 10.14 and Ubuntu 18.x)

Some setup steps must be completed by hand after the scripts here have run, which include:

- Registering a GitLab runner (currently, this can only be done through the Gitlab web interface)
- Creating a new project in GitLab (again, via the GitLab web interface)
- Filling in environment variables for the new GitLab project (again, via the GitLab web interface)
- Pushing the initial demo application to GitLab (done using Git on your local machine)

## Resources Created

Running the scripts here will create the following resources:

- 1xECS (GitLab host)
- 1xECS (GitLab runner)
- 1xECS (SonarQube)
- 1xRDS (SonarQube PostgreSQL database)
- 1xOSS (GitLab configuration backups and SSL certificates for the deployed application)
- 1xDirectMail (**created manually** via the Alibaba Cloud console)

Depending on which version of the sample 'todolist' application you deploy, you will also end up with these additional resources:

3xSLB (todolist application load balancer)
3xECS (SSL certificate management machines for dev, pre-prod, and production environments)
6xECS (todolist application servers)
3xRDS (todolist MySQL database servers)

These numbers assume you have configured development, production, and preproduction environments for the 'todolist' application. **You will be charged for these resources while they are running** so consider tearing down and rebuilding this environment as-needed. At minimum, you could stop the ECS instances when not in use, or make snapshots of their disks and then recreate them later as-needed.

## Contents of this repository

Currently, the repository holds the following files:

```
COMING SOON
```

## Why

The concept of "DevOps" is broad and encompasses a lot of different tools and ways of doing things. Cultivating a CI/CD workflow also takes time and involves solving numerous complex issues around application deployment, logging, and debugging. Having a toy environment to play with and serve as a model for future applications can help you better understand which direction you should take in adopting your own *DevOps Best Practices*.

## How

COMING SOON

## Notes and Warnings

COMING SOON

## Architecture

The full pipeline looks like this:

![DevOps Architecture](diagrams/gitlab-ci-cd.png)
