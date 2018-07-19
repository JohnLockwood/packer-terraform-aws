/* Terraform Variables.  These are set in the bash script cloud_haiku.sh */
variable "region" {}
variable "ami_image" {}
variable "key_name" {}
variable "public_key" {}

/* First time through we need to call "terraform init" */
provider "aws" {
  region     = "${var.region}"
}


/* Enable ssh access to this resource using the key-pair created by our bash script.  */
resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key)}"
}

/* Get our local machine's IP address for good-enough-for-demo security */
data "http" "ip" {
  url = "http://icanhazip.com"
}

/* 
  Create a security group to allow SSH access.  
  Limit IP addresses access to local machine IP we got in the last step. 
*/
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH to the cloud haiku instance."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "${chomp(data.http.ip.body)}/32"
    ]
  }
}

/*
  With the security group and keypair in place, we're ready 
  to create our ec2 instance based on the AMI that packer created.
*/
resource "aws_instance" "cloud-haiku" {
  ami           = "${var.ami_image}"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.allow_ssh.name}" ]
  key_name = "${aws_key_pair.deployer.key_name}"
  tags = {
    Name = "cloud-haiku"
  }

  /* Create a login script since we know the IP.  An alternative would be to do that in the parent script */
  provisioner "local-exec" {
    command = "echo ssh -oStrictHostKeyChecking=no ubuntu@${aws_instance.cloud-haiku.public_ip} -i ${var.key_name} > sshlogin.sh"    
  }
}
