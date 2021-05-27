## Enable data sync from Commercetools to Algolia

### Contributing

Contributions are more than welcome! Please create a branch, commit your code and create a pull request.
Please make sure you document your changes, and that you use [conventional commit guidelines](https://www.conventionalcommits.org/en/v1.0.0/) when commiting.

### Structure
This repository comprises of two parts:
1. A lambda function (`commercetools-lambda`)
2. A terraform script (`terraform-lambda-sns`)

The lambda function code is needed for the terraform script, and it handles the processing and updating of a product into algolia.

The lambda currently does three things:
- Parse the event and retrieve the commercetools product ID from the SNS message
- Fetch the full product from Commercetools
- Update the product inside algolia using [save objects](https://www.algolia.com/doc/api-reference/api-methods/save-objects/)

The lambda currently only supports:
- A product which is created/published in commercetools

The terraform script does three things:
- Create a message queue (SNS) connected to a lambda in AWS 
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

### Testing the lambda event
You can test the lambda event locally using SAM in order to adjust the function to your specific needs. There is a sample event in the root of `commercetools-lambda`

1. Make sure [sam is installed locally](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)

2. In the `commercetools-lambda` directory, run `sam local invoke -e example-event.json CommercetoolsLambda`

### Roadmap
Found in Github issues + projects
