
data "archive_file" "this" {
  type        = "zip"
  source_dir  = "./nodejs"
  output_path = "hello.zip"

  depends_on = [
    random_string.r
  ]
}

resource "aws_iam_role" "this" {
  name = "${local.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "policy"
    policy = data.aws_iam_policy_document.this.json
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
}



resource "aws_lambda_function" "this" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "hello.zip"
  function_name = "hello"
  handler       = "index.handler"
  role          = aws_iam_role.this.arn
  source_code_hash = data.archive_file.this.output_base64sha256

  runtime = "nodejs18.x"
}


/*

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name = "hello-world-lambda"
  handler = "index.handler"
  runtime = "nodejs14.x"
  role = aws_iam_role.lambda_execution_role.arn

  filename = "handler.js" # You'll create this ZIP file in a later step

  source_code_hash = filebase64sha256("handler.js")
}
*/