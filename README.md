# weather-ecs-fargate-react-app

## Bootstrap 

**Prerequisites**:

* Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
* Install [jq](https://stedolan.github.io/jq/download/)
* AWS credentials configured in your AWS CLI or via environment variables.

**How to bootstrap your environment**

Populate the environment variables on your command line
```
GITHUB_ORG=<enter the GitHub Org Name>
GITHUB_REPO=<enter the GitHub repository name>
ROLE_NAME=<name of the IAM role for AWS configure credentials action that will be created. It must not be an exising IAM role.>
ECR_REPO=<enter the ECR repository name. It will be created if it doesn't already exist.>
AWS_REGION=us-east-1
AVAILABILITY_ZONES=us-east-1a,us-east-1b,us-east-1c
ECS_CLUSTER_NAME=<enter the ECS cluster name>
```

Bootstrap the AWS account using the following command
```
aws cloudformation deploy --template-file ./templates/bootstrap-minimal.yaml --stack-name bootstrap --parameter-overrides GitHubOrganization=$GITHUB_ORG RepositoryName=$GITHUB_REPO RoleName=$ROLE_NAME ECRRepositoryName=$ECR_REPO AvailabilityZones=$AVAILABILITY_ZONES ECSClusterName=$ECS_CLUSTER_NAME --region $AWS_REGION --capabilities CAPABILITY_NAMED_IAM
```

Get the stacks outputs using the following command
```
aws cloudformation describe-stacks --stack-name bootstrap --region us-east-1 | jq ".Stacks[0].Outputs[]"
```
Example output
```json
{
  "OutputKey": "VPCStackName",
  "OutputValue": "bootstrap-VPCStack-XXXXXXXXXXXX",
  "Description": "VPC Stack Name for import"
}
{
  "OutputKey": "ECRRepositoryName",
  "OutputValue": "new-weather-app",
  "Description": "ECR Repository Name"
}
{
  "OutputKey": "RoleGithubActionsARN",
  "OutputValue": "arn:aws:iam::XXXXXXXXXXXX:role/new-oidc-user-role",
  "Description": "CICD Role for GitHub Actions"
}
{
  "OutputKey": "AWSRegion",
  "OutputValue": "us-east-1",
  "Description": "AWS Region for stack deployment"
}
{
  "OutputKey": "IdpGitHubOidc",
  "OutputValue": "arn:aws:iam::XXXXXXXXXXXX:oidc-provider/token.actions.githubusercontent.com",
  "Description": "ARN of Github OIDC Provider"
}
```

Create a new GitHub environment based of the branch name. Configure vars and secrets as follow

Secrets: 
* `ROLE_TO_ASSUME` = the output value of `RoleGithubActionsARN` from CloudFormation output

Vars: 
* `AWS_REGION` = the output value of 'AWSRegion' from CloudFormation output
* `ECR_REPO_NAME` =  the output value of `ECRRepositoryName` from CloudFormation output
* `VPC_STACK_NAME` =  the output value of `VPCStackName` from CloudFormation output
* `ECS_CLUSTER_NANE` =  enter name of ECS cluster to be created
* `APP_NAME` = enter name of the app to be shown in ECS cluster

## Test

To manually test the workflow, trigger the `build-and-deploy` workflow against the branch.
