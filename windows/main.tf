data "aws_ami" "windows_servers" {
  for_each = {
    "Windows_Server_2019" = {
      name = "Windows_Server-2019-English-Full-Base-*"
    },
    "Windows_Server_2022" = {
      name = "Windows_Server-2022-English-Full-Base-*"
    }
  }

  most_recent = true
  owners      = ["801119661308"]
  filter {
    name   = "name"
    values = [each.value.name]
  }
}

resource "aws_instance" "windows" {
  for_each = {
    "${var.name}-Windows_Server_2022" = data.aws_ami.windows_servers["Windows_Server_2022"].id,
    "${var.name}-Windows_Server_2019" = data.aws_ami.windows_servers["Windows_Server_2019"].id
  }

  ami           = each.value
  instance_type = "t2.micro"
  key_name      = "ansible" # Provide the name of your SSH key stored in AWS
  subnet_id = "subnet-05497b763e6d89677" # Provide the subnet ID where you want to launch your instances

  tags = {
    Name = each.key
  }

  user_data = <<-EOF
    <powershell>
    #Create ansible user
    $username = "ansible"
    $password = ConvertTo-SecureString -String "password123" -AsPlainText -Force
    New-LocalUser -Name $username -Password $password
    Set-LocalUser -Name $username -PasswordNeverExpires 1
    Add-LocalGroupMember -Group "Administrators" -Member $username

    #Configure WinRM
    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    powershell.exe -ExecutionPolicy ByPass -File $file
    winrm enumerate winrm/config/Listener
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    </powershell>
  EOF
}
