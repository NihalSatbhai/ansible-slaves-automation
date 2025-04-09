# Ansible Slaves Automation


This project is all about creation and configuration of ansible slaves of different OS types like Debian, Redhat and Windows. You'll get your slaves configured based on your selecting OS type in one click. The infrastructure is creating on AWS Cloud. Just make sure you don't forget to destroy the slaves once you are done using them.

There are some points you should know before using this terraform code.
1. Uncomment the module you want to use along with output value of the module
   e.g if you wish to use debian module you will uncomment the module defined with debian name in main.tf and output associated with debian module in outputs.tf
2. Please provide default value to variable named "name" in variable.tf so you won't have to always pass the value of
   var.name through command line and the value will be your actual name
3. You need to change the value of profile in provider.tf so you can authenticate to AWS

Points you should be taking care of on your master nodes
1. for windows slaves you just have to add the below variables in your hostfile or anywhere in group vars
    ansible_user: ansible
    ansible_password: password123
    ansible_connection: winrm
    ansible_winrm_server_cert_validation: ignore
    ansible_winrm_transport: basic
    ansible_winrm_port: 5986

2. for debian and redhat slaves you should mention the following block in your ansible.cfg
    [defaults]
    remote_user = ansible
    private_key_file = /path/to/your/private/key

    You can store the private key present in the source code itself anywhere on your master node just make sure you are giving the right path of the private key above

3. Once you done the terraform apply you will get the list of IPs which you need to specify in your hostfile on master node

THANK YOU.

# Author

Nihal Satbhai,
DevOps Engineer