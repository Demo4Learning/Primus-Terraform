
output "server" {
  value = aws_instance.primusb-server.public_ip

}

output "vpc_id" {
  value = aws_vpc.primusb-vpc.id
}


output "server-arn" {
  value = aws_instance.primusb-server.arn
}