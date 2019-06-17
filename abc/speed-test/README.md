# Stress Test: Performance and Network Testing

## What

This terraform script sets up a single ECS instance and installs some stress testing and network performance testing tools (iperf, stress).

- iperf is used for network throughput testing
- stress is used to create arbitrary CPU, memory, and disk loads

The "stress" tool is there mostly for testing things like auto scaling group rules and monitoring/alerts (i.e. test that you receive an email if CPU load climbs above X% for Y minutes).

## Why

Network performance is important when choosing a cloud provider. Automated alerts and management are also important. If you need an easy way to test these things, this script is your friend.

## How 

From your command line, "cd" into this directory. Then run:

```
terraform init
```

And then:

```
terraform plan
```

Check the output. It should show that a security group, VPC group, vSwitch, and ECS instance be created. Once you have confirmed that all the necessary resources will be created, run:

```
terraform apply
```

Say "yes" to the prompt. That's it! In a few minutes you'll have a working environment. Log into the instance to start iperf or run the "stress" command. 

When you are done with your tests, run:

```
terraform destroy
```

## Architecture

Once `terraform apply` has run successfully, you end up with an architecture that looks like this:

![Stress and Network Testing Environment](diagrams/ubuntu_speed_test.png)

