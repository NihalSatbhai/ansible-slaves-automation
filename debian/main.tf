data "aws_ami" "ubuntu" {
  for_each = {
    "${var.name}-ubuntu-18.04" = "ubuntu-bionic-18.04-amd64-server-*",
    "${var.name}-ubuntu-20.04" = "ubuntu-focal-20.04-amd64-server-*",
    "${var.name}-ubuntu-22.04" = "ubuntu-jammy-22.04-amd64-server-*",
  }

  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/${each.value}"]
  }
}

resource "aws_instance" "debian" {
  for_each = data.aws_ami.ubuntu

  ami           = each.value.id
  instance_type = "t2.micro"
  key_name      = "kanfig" # Provide the name of your SSH key stored in AWS
  subnet_id = "subnet-0cd66111f7673b42d" # Provide the subnet ID where you want to launch your instances

  tags = {
    Name = each.key
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("private.pem") # Provide the name of your private key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "private.pem" 
    destination = "/home/ubuntu/.ssh/private.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y openssh-server",
      "sudo adduser --disabled-password --gecos '' ansible",
      "sudo usermod -aG sudo ansible",
      "sudo sed -i '/^%sudo/ a ansible ALL=(ALL) NOPASSWD: ALL' /etc/sudoers",
      "sudo mkdir /home/ansible/.ssh",
      "sudo chown ansible:ansible /home/ansible/.ssh",
      "sudo chmod 700 /home/ansible/.ssh",
      "sudo touch /home/ansible/.ssh/authorized_keys",
      "sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys",
      "sudo chmod 600 /home/ansible/.ssh/authorized_keys",
      "sudo cat /home/ubuntu/.ssh/authorized_keys | sudo tee -a /home/ansible/.ssh/authorized_keys",
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config",
      "sudo systemctl restart ssh"
    ]
  }
}