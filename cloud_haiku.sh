# Set up variables used by packer and terraform
key_name=haiku_key
region=us-east-2
source_ami=ami-6a003c0f

# Generate a key using OpenSSH
if [ ! -f "${key_name}.pub" ]; then 
  echo "Creating key ${key_name}"
  ssh-keygen -t rsa -b 4096 -q -N "" -f "${key_name}"
else
  echo "Key ${key_name} exists, skipping key generation"
fi

# Build an ami AMI image, storing results so we can parse AMI out and pass it to terraform
echo "Building AMI Image based on source AMI $source_ami"
packer build -var source_ami="$source_ami" -var region="$region"  packer.json 2>&1 | tee output.txt
if [ $? -ne 0 ]; then
	echo "Packer build failed, exiting"
	exit 1
fi

# Parse the ami ID from the packer output to pass to Terraform
target_ami=`tail -2 output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }'`

echo "Built AMI $target_ami using Packer, now launching it using Terraform"
terraform apply -auto-approve -var ami_image="${target_ami}" -var key_name="${key_name}" -var public_key="${key_name}.pub" -var region="${region}"

# On success wait for the machine to come up (on failure Terraform already displayed an error).
if [ $? -eq 0 ]; then
	echo "Sleeping for 10 seconds to allow machine to be ready..."
	sleep 10
	# Terraform has created this login script for us since it has knowledge of public ip 
	# (todo could have output it again)
	chmod 777 ./sshlogin.sh
	./sshlogin.sh
fi

# Clean up our temporary file
if [ -f output.txt ]; then
	rm output.txt
fi
