output "get_original_url_function_url" {
  value = aws_lambda_function_url.get_original_url.function_url
}

output "get_short_url_function_url" {
  value = aws_lambda_function_url.get_short_url.function_url
}

output "get_url_stats_function_url" {
  value = aws_lambda_function_url.get_url_stats.function_url
}