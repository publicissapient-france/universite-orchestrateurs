#
# Export the following env variables:
#   export AWS_ACCESS_KEY=change-me
#   export AWS_SECRET_KEY=change-me
#   export AWS_REGION=eu-central-1
#

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"

    #values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20161214-d83d0782-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Canonical

  #name_regex = "^ubuntu/images/.*/ubuntu-xenial-16.04-amd64-server-20160420\.3"
}

data "aws_route53_zone" "xebia_public_dns" {
  name = "aws.xebiatechevent.info."
}

variable "public_subdomain" {
  type = "string"
}

resource "aws_key_pair" "access" {
  key_name_prefix = "mesos-starter"
  public_key      = "${file("${path.module}/../mesos-starter.pub")}"
}

variable "owner" {
  type = "string"
}

# Mesos
variable "mesos-worker_count" {
  type = "string"
}

variable "mesos-master_count" {
  type = "string"
}

# Swarm
variable "swarm-worker_count" {
  type = "string"
}

variable "swarm-master_count" {
  type = "string"
}

# Swarm
variable "kubernetes-worker_count" {
  type = "string"
}

variable "kubernetes-master_count" {
  type = "string"
}

variable "monitoring_count" {
  type = "string"
}

provider "aws" {
  region = "eu-west-1"

  //  region = "eu-central-1"
}

variable "vpc_id" {}
variable "project_name" {}
