output "vpc_id" {
  value = aws_vpc.ale_vpc.id
}
output "subnet_id1" {
  value = aws_subnet.public-1.id
}
output "subnet_id2" {
  value = aws_subnet.public-2.id
}
output "private_subnet_id" {
  value = aws_subnet.private_1.id
}
