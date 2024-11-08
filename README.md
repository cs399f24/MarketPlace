# MarketPlace
## Overview
An online web application that allows users to interact with each other in a virtual marketplace to buy and sell products.

## System Architecture
![System Diagram](https://github.com/cs399f24/MarketPlace/blob/main/project_structure.png)

## Local Deployment:

* Set up a virtual environment

* Install requirements.txt

* Launch in the terminal by running `python3 app.py`

* Navigate to `http://192.168.1.122:5000` to view page

* Stop using `CRTL+C` as prompted

## AWS Deployment:

* Create AWS VPC:
     * Select VPC and more
     * Set CIDR block to "<generated-IP>/24"
     * Select 2 Availability Zones(AZ), 2 public and private subnets
     * Everything else is default, create vpc
* Create AWS EC2:
     * Key pair name: select Vockey
     * Network Setting select Edit: select the VPC previously created, a public subnet, and add a security group rule allowing HTTP traffic
     * Advanced details: select LabInstance Profile for the IAM instance profile and copy userdata.sh code in userdata
     * Everything else is default, launch instance
* Create s3 bucket:
     * Deselect Block all public access
     * Acknowledge the warning message
     * Everything else is default, create bucket
