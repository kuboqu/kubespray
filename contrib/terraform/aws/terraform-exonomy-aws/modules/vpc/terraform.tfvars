

be_allowed_rules = [
  { from_port = 80, to_port = 80, protocol = "tcp", sg_source = "sg-frontend-id" }
]

db_allowed_rules = [
  { from_port = 3306, to_port = 3306, protocol = "tcp", sg_source = "sg-backend-id" }
]

