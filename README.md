# Development Organization

This module manages the development environment infrastructure for the ASL Dataset project, including:

- SageMaker domains and user profiles for data scientists
- Development storage buckets
- IAM roles and policies for development access
- Cross-account access to data resources

## Components

- `iam.tf` - IAM roles and policies for development access
- `s3.tf` - Storage buckets for development data and artifacts
- `sagemaker.tf` - SageMaker workspace configuration
- `outputs.tf` - Exported resource identifiers for use by other modules

## Usage

Deploy this module to set up the development environment for data scientists and ML engineers.

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

The module exports SageMaker domain IDs, user profiles, bucket names, and role ARNs that can be used by developers and other services.