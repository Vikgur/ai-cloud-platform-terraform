output "logging_endpoint" {
  value = module.logging.endpoint
}

output "metrics_endpoint" {
  value = module.monitoring.endpoint
}

output "tracing_endpoint" {
  value = module.tracing.endpoint
}
