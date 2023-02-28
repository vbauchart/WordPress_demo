terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.7.0"
    }
  }

  required_version = ">= 1.1.7"
}

variable "aws_region_name" {
  type    = string
  default = "eu-west-3"
}

variable "aws_az_name" {
  type    = string
  default = "eu-west-3a"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/aws_word_press"
}

provider "aws" {}
