# Asterisk demo system

The main usage of this terraform script is to setup an asterisk system for my personal training purpose.

The script will launch an EC2 instance and makes it publicly accessible. On startup an asterisk system is compiled and bootstraped.
The hello-world example from the asterisk documenation is also set up.

Furthermore I played around with an example of the ari-client package and refactored it a bit as the code was a bit rusty.

# Usage

0. Make sure your aws cli is authorized
1. Change the backend of the terraform script in main.tf
2. Create a local.tfvars file with the input variables from options.tf
3. Execute command: _terraform apply -var-file="local.tfvars"_

# !!! DO NOT USE IT IN PRODUCTION !!!
