output "instance_ips" {
  value = [for instance in aws_instance.windows : instance.public_ip]
}