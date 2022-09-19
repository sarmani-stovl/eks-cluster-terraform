output "private_subnets" {
  value = ["${aws_subnet.subnet-1.id}","${aws_subnet.subnet-2.id}","${aws_subnet.subnet-3.id}"]
}


