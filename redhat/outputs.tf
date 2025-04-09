output "instance_ips" {
  value = [for instance in aws_instance.redhat : instance.public_ip]
}