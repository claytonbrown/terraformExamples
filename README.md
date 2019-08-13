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

Which you can follow with a destroy command when you're done playing with the newly created cloud resources:

```terraform destroy```

In some cases, setup and destroy scripts are included, in which case running the scripts consists of:

```
terraform init
./setup.sh
```

Follow later by:

```
./destroy.sh
```

I won't necessarily provide the same set of scripts for each cloud provider, but I will try to do so wherever it's possible. 

License
=======

Everything in this repository is licensed under the [MIT License](https://en.wikipedia.org/wiki/MIT_License). Feel free to copy, modify, and reuse. Share the love!