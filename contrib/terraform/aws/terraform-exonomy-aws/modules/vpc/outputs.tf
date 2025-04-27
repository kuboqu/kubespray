output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "db_subnet_ids" { value = aws_subnet.db[*].id }
output "ops_subnet_ids" { value = aws_subnet.ops[*].id }

output "fe_sg" { value = aws_security_group.fe_sg.id }
output "be_sg" { value = aws_security_group.be_sg.id }
output "db_sg" { value = aws_security_group.db_sg.id }
output "ops_sg" { value = aws_security_group.ops_sg.id }
