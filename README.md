# Integrating Packer and Terraform Using Bash

This demo project shows how to create a dead-simple build pipeline using:

* _Bash_:  To create a key-pair (on Windows needing OpenSSH on the path) for SSH login, and to orchestrate the entire build.
* _Packer_: To build a simple AMI image based on Ubuntu.  We'll add a message of the day that displays a haiku when the user logs in.  
* _Terraform_: To upload the public key information to AWS, create a security group allowing SSH access, and launch an EC2 instance based on the AMI that we created using Packer.  For demo purposes we provide reasonable security by limiting SSH access to the current machine only using icanhazip.  (Production security would utilize a bastion server or other mechanism).  Finally, Terraform knows about the public IP of the newly created instance, so we create the ssh login script that the bash script will call after the EC2 instance loads.  This can also 

## Requirements

* You must have AWS configured to connect to your account (this demo is eligible for free tier).  If you use the AWS cli, you may have configuration options stored at $HOME\.aws\credentials.  Otherwise see the [Terraform documentation](https://www.terraform.io/docs/providers/aws/index.html) for other options.
* [Terraform](https://www.terraform.io/downloads.html), [Packer](https://www.packer.io/downloads.html) , and OpenSSH must be on your path.  For OpenSSH, On Linux / MAC, you likely already have it.  Windows, OpenSSH is part of the Git for Windows package, which will also install a bash shell to run the script.

## Usage

```
terraform init
chmod u+x cloud_haiku.sh
./cloud_haiku.sh
```

You should see the haiku message of the day when the script automatically logs you in.  Note that creating the AMI, deploying it, and logging you in will take some time (typically 5-10 minutes).

## Cleanup

After exiting out of the SSH script, you can use the "destroy.sh" script to delete the resources that Terraform created.  Since it is not managed by terraform, the AMI that Packer creates will need to be deleted separately by loggging into the AWS console, changing region to US East (Ohio) and going to Services / EC2 and clicking on AMIs.  Filter by "Owned by Me" or "Private Images" and look for the name beginning "Ubuntu Haiku Server".  You should also delete any snapshots associated with the AMIs.

## Article

A forthcoming article will walk through the sample in detail.  I'll provide a link here when published.