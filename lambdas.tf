data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

###########################
## GET SHORT URL LAMBDA ###
###########################

data "archive_file" "get_short_url" {
  type        = "zip"
  source_dir  = "./functions/get-short-url"
  output_path = ".build/get-short-url.zip"
}

resource "aws_lambda_function" "get_short_url" {
  filename         = data.archive_file.get_short_url.output_path
  function_name = local.get_short_url_function_name
  role          = aws_iam_role.get_short_url.arn
  handler       = "index.handler"
  source_code_hash = data.archive_file.get_short_url.output_base64sha256
  runtime = "nodejs18.x"
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.short_urls.id,
      DOMAIN_NAME = local.domain_name,
      DOMAIN_PROTOCOL = local.domain_protocol
    }
  }
}

resource "aws_lambda_function_url" "get_short_url" {
  function_name      = aws_lambda_function.get_short_url.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "get_short_url" {
  name = "${local.get_short_url_function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "get_short_url" {
  name        = "${local.get_short_url_function_name}-permissions-policy"
  description = "Lambda permissions policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.short_urls.arn}"
    },
    {
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"

    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.get_short_url_function_name}:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_short_url" {
  role       = aws_iam_role.get_short_url.name
  policy_arn = aws_iam_policy.get_short_url.arn
}


###########################
# GET ORIGINAL URL LAMBDA #
###########################

data "archive_file" "get_original_url" {
  type        = "zip"
  source_dir  = "./functions/get-original-url"
  output_path = ".build/get-original-url.zip"
}

resource "aws_lambda_function" "get_original_url" {
  filename         = data.archive_file.get_original_url.output_path
  function_name = local.get_original_url_function_name
  role          = aws_iam_role.get_original_url.arn
  handler       = "index.handler"
  source_code_hash = data.archive_file.get_original_url.output_base64sha256
  runtime = "nodejs18.x"
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.short_urls.id
    }
  }
}

resource "aws_lambda_function_url" "get_original_url" {
  function_name      = aws_lambda_function.get_original_url.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "get_original_url" {
  name = "${local.get_original_url_function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "get_original_url" {
  name        = "${local.get_original_url_function_name}-permissions-policy"
  description = "Lambda permissions policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.short_urls.arn}"
    },
    {
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"

    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.get_original_url_function_name}:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_original_url" {
  role       = aws_iam_role.get_original_url.name
  policy_arn = aws_iam_policy.get_original_url.arn
}

###########################
#  GET URL STATS LAMBDA   #
###########################

data "archive_file" "get_url_stats" {
  type        = "zip"
  source_dir  = "./functions/get-url-statistics"
  output_path = ".build/get-url-statistics.zip"
}

resource "aws_lambda_function" "get_url_stats" {
  filename         = data.archive_file.get_url_stats.output_path
  function_name = local.get_url_stats_function_name
  role          = aws_iam_role.get_url_stats.arn
  handler       = "index.handler"
  source_code_hash = data.archive_file.get_url_stats.output_base64sha256
  runtime = "nodejs18.x"
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.short_urls.id,
      DOMAIN_NAME = local.domain_name,
      DOMAIN_PROTOCOL = local.domain_protocol
    }
  }
}

resource "aws_lambda_function_url" "get_url_stats" {
  function_name      = aws_lambda_function.get_url_stats.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "get_url_stats" {
  name = "${local.get_url_stats_function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "get_url_stats" {
  name        = "${local.get_url_stats_function_name}-permissions-policy"
  description = "Lambda permissions policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.short_urls.arn}"
    },
    {
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"

    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.get_url_stats_function_name}:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_url_stats" {
  role       = aws_iam_role.get_url_stats.name
  policy_arn = aws_iam_policy.get_url_stats.arn
}