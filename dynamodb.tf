resource "aws_dynamodb_table" "short_urls" {
  name           = "url-shortener-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ShortValue"

  attribute {
    name = "ShortValue"
    type = "S"
  }
}