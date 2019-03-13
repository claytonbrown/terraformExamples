Terraform Examples
==================

This repository is a personal collection of small Terraform examples and patterns. Feel free to use and modify any of the scripts you find here.

Currently, only scripts for Alibaba Cloud are available, but I plan to support all of these cloud platforms in the future:

- Alibaba Cloud
- Amazon AWS
- Google Cloud Platform
- Microsoft Azure

Structure
=========

Each example is built to be run independently of the others. Examples for each cloud provider are grouped into separate directories:

- abc (Alibaba Cloud)
- aws (Amazon AWS)
- azure (Microsoft Azure)
- gcp (Google Cloud Platform)

Further, each example has its own subdirectory. Right now, some of these directories are missing, but eventually the tree should look something like this:

```
.
├── LICENSE
├── README.md
├── abc
│   └── chrome-on-windows
│       ├── install_chrome.ps1
│       ├── main.tf
│       ├── outputs.tf
|       └── README
│       └── variables.tf
│   └── scalable-wordpress
│       ├── setup.sh
│       ├── main.tf
│       ├── outputs.tf
|       └── README
│       └── variables.tf
├── aws
│   └── chrome-on-windows
│       ├── install_chrome.ps1
│       ├── main.tf
│       ├── outputs.tf
|       └── README
│       └── variables.tf
│   └── scalable-wordpress
│       ├── setup.sh
│       ├── main.tf
│       ├── outputs.tf
|       └── README
│       └── variables.tf
├── azure
│   └── chrome-on-windows
    ...and so on

```

You should be able to descend into any project directory, like `aws/scalable-wordpress` and then simply run the scripts there like so:


```
terraform init
terraform plan
terraform apply
```

I won't necessarily provide the same set of scripts for each cloud provider, but I will try to do so wherever it's possible. 

License
=======

This repository is licensed under "The Unlicense" so feel free to use the content here in any way you like.