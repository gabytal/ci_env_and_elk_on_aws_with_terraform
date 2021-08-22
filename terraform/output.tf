output "arn" {
    value = aws_elasticsearch_domain.es.arn
}
output "domain_id" {
    value = aws_elasticsearch_domain.es.domain_id
}
output "domain_name" {
    value = aws_elasticsearch_domain.es.domain_name
}
output "es_endpoint" {
    value = aws_elasticsearch_domain.es.endpoint
}
output "kibana_endpoint" {
    value = aws_elasticsearch_domain.es.kibana_endpoint
}

output "ci-prod-machine-ip" {
    value = aws_instance.ci_prod_machine.public_ip
}

output "ecr-repo-url" {
    value = aws_ecr_repository.flask_app.repository_url
}
