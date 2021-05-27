terraform {
  required_providers {
    commercetools = {
      source = "labd/commercetools"
      version = "0.29.2"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.42.0"
    }
  }
}

# Initialise the AWS provider
provider "aws" {
  region = "us-east-1"
}


# Create a ZIP archive of the Lambda code to upload to AWS
data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "../commercetools-lambda"
  output_path = "../lambda.zip"
}

// Create an SNS topic to receive events from Commercetools
resource "aws_sns_topic" "commercetools-product-updates" {
  name = "commercetools-product-updates"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 1,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

// Ensure permissions for Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

// Create log group so Lambda can log
resource "aws_cloudwatch_log_group" "terraform-lambda-test_log_group" {
  name              = "/aws/lambda/terraform-lambda-test"
  retention_in_days = 14
}


// Ensure permissions for lambda to log
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

// Create/upload the lambda function to receive messages from SNS
resource "aws_lambda_function" "commercetools_product_updates_lambda" {
  filename      = "${data.archive_file.lambda.output_path}"
  function_name = "terraform-lambda-test"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "exports.update"
  runtime       = "nodejs12.x"
  depends_on    = [aws_cloudwatch_log_group.terraform-lambda-test_log_group, aws_iam_role.iam_for_lambda, aws_iam_role_policy_attachment.lambda_logs]

  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"

  environment {
    variables = {
      lambda_client_id = var.commercetools_lambda_client_id
      lambda_client_secret = var.commercetools_lambda_client_secret
      lambda_algolia_api_key = var.commercetools_lambda_algolia_api_key
    }
  }
}

// Connect the SNS queue to the Lambda to receive events
resource "aws_sns_topic_subscription" "commercetools_product_updates_sns_target" {
  topic_arn = "${aws_sns_topic.commercetools-product-updates.arn}"
  protocol  = "lambda"
  endpoint = "${aws_lambda_function.commercetools_product_updates_lambda.arn}"
}
resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.commercetools_product_updates_lambda.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.commercetools-product-updates.arn}"
}

# Initialise the commercetools provider
provider "commercetools" {
  client_id     = var.commercetools_client_id
  client_secret = var.commercetools_client_secret
  project_key   = var.commercetools_project_key
  scopes        = var.commercetools_project_scopes
  token_url     = var.commercetools_token_url
  api_url       = var.commercetools_api_url
}

resource "aws_iam_user" "ct" {
  name = "commercetools-iam-user"
}

resource "aws_iam_access_key" "ct" {
  user = "${aws_iam_user.ct.name}"
}

// Ensure permissions for AWS SNS topic
resource "aws_iam_user_policy" "policy" {
  name = "commercetools-access"
  user = "${aws_iam_user.ct.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.commercetools-product-updates.arn}"
    }
  ]
}
EOF
}

# Create subscription in  commercetools to emit events to SNS queue
resource "commercetools_subscription" "products-sns-subscribtion" {
  key = "commercetools-product-updates-subscription"

  destination = {
    type          = "SNS"
    topic_arn     = "${aws_sns_topic.commercetools-product-updates.arn}"
    access_key    = "${aws_iam_access_key.ct.id}"
    access_secret = "${aws_iam_access_key.ct.secret}"
    region        = "us-east-1"
  }

  changes {
    resource_type_ids = ["product"]
  }

  message {
    resource_type_id = "product"
    types            = ["ProductPublished", "ProductCreated"]
  }
}