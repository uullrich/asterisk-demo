# Asterisk demo system

The main usage of this terraform script is to setup an asterisk system for my personal training purpose.

The script will launch an EC2 instance and makes it publicly accessible. On startup an asterisk system is compiled and bootstraped.
The hello-world example from the asterisk documenation is also set up.

Furthermore I played around with an example of the ari-client package and refactored it a bit as the code was a bit rusty.

# Usage

0. Make sure your aws cli is authorized
1. Change the backend of the terraform script
2. Set the options in options.tf
3. Execute command: _terraform apply_

# !!! DO NOT USE IT IN PRODUCTION !!!
