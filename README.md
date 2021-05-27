## Enable data sync from Commercetools to Algolia

### Structure
This repository comprises of two parts:
1. A lambda function
2. A terraform script

The lambda function code is needed for the terraform script, and it handles the processing and updating of a product into algolia.

The terraform script does three things:
- Create a message queue (SQS) connected to a lambda in AWS 
- Create a subscription in commercetools to pass events to the message queue
- Connect the subscription to the queue to the lambda so new products get added to algolia

### Requirements
1. AWS account + CLI
2. Commercetools account
3. Algolia account

### Usage

#### In commercetools-lambda folder
1. Rename .example.env to .env and add your own values where "XXXX" is specified

#### In terraform-lambda-sns folder
1. Rename example.variables.tf to variables.tf, uncomment all lines and add your own values where "XXXX" is specified

2. Ensure you have [installed Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) and [configured it for use with AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)

3. Run `terraform init`, then `terraform plan` to ensure the configuration is set up successfully, you will receive a view of everything that will be created.

4. Run `terraform apply` to create all of the needed infrastructure on commercetools and AWS.