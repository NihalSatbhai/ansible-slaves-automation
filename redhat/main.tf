data "aws_ami" "linux" {
  for_each = {
    "${var.name}-amazon_linux_2"          = "amzn2-ami-hvm-*-x86_64-gp2"
    "${var.name}-redhat_enterprise_linux" = "RHEL-9*_HVM-*-x86_64-24-Hourly2-GP2"
  }

  most_recent = true
  owners      = each.value == "amzn2-ami-hvm-*-x86_64-gp2" ? ["137112412989"] : ["309956199498"]
  filter {
    name   = "name"
    values = [each.value]
  }
}

resource "aws_instance" "redhat" {
  for_each = data.aws_ami.linux

  ami           = each.value.id
  instance_type = "t2.micro"
  key_name      = "ansible" # Provide the name of your SSH key stored in AWS
  subnet_id = "subnet-00035a1ed063ea18c" # Provide the subnet ID where you want to launch your instances

  tags = {
    Name = each.key
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("private.pem") # Provide the name of your private key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "private.pem"
    destination = "/home/ec2-user/.ssh/private.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y openssh-server",
      "sudo useradd -m ansible",
      "sudo usermod -aG wheel ansible",
      "sudo sed -i '/^# %wheel/ a ansible ALL=(ALL) NOPASSWD: ALL' /etc/sudoers",
      "sudo mkdir /home/ansible/.ssh",
      "sudo chown ansible:ansible /home/ansible/.ssh",
      "sudo chmod 700 /home/ansible/.ssh",
      "sudo touch /home/ansible/.ssh/authorized_keys",
      "sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys",
      "sudo chmod 600 /home/ansible/.ssh/authorized_keys",
      "sudo cat /home/ec2-user/.ssh/authorized_keys | sudo tee -a /home/ansible/.ssh/authorized_keys",
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config",
      "sudo systemctl restart sshd"
    ]
  }
}