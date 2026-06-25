variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  description = "Amazon linux 2023"
  default     = "ami-084dc2104994adeec"
}

variable "key_name" {
  description = "EC2_SSH_KEY"
}
