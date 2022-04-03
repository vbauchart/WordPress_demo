terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.7.0"
    }
  }

  required_version = ">= 1.1.7"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/aws_word_press"
}

variable "bastion_ssh_port" {
  type    = number
  default = 7710
}
