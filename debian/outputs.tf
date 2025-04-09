output "instance_ips" {
  value = [for instance in aws_instance.debian : instance.public_ip]
}