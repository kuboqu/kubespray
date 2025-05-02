output "nlb_arn" { value = aws_lb.aws-nlb-api.arn }
output "nlb_dns_name" { value = aws_lb.aws-nlb-api.dns_name }
output "nlb_api_id" { value = aws_lb.aws-nlb-api.id }
output "nlb_api_fqdn" { value = aws_lb.aws-nlb-api.dns_name }
output "nlb_api_tg_arn" { value = aws_lb_target_group.aws-nlb-api-tg.arn }
