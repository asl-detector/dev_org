# Remote state access for AWS organization structure
data "terraform_remote_state" "org_structure" {
  backend = "s3"
  config = {
    bucket = "terraform-state-asl-foundation"
    key    = "organization/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  account_ids = data.terraform_remote_state.org_structure.outputs.account_ids
}

# Remote state access for data_org resources
data "terraform_remote_state" "data_org" {
  backend = "s3"
  config = {
    bucket = "terraform-state-asl-foundation"
    key    = "data_org/terraform.tfstate"
    region = "us-west-2"
  }
}

# Create IAM role to assume data_org role for cross-account access to clean data lake
resource "aws_iam_role" "data_lake_access_role" {
  name = "${var.project_name}-data-lake-access"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy to allow SageMaker to assume the role in data_org for clean data lake
resource "aws_iam_role_policy" "assume_data_org_role_policy" {
  name = "assume-data-org-role-policy"
  role = aws_iam_role.data_lake_access_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Resource = data.terraform_remote_state.data_org.outputs.data_lake_clean_access_role_arn
    }]
  })
}

# Create IAM role to assume data_org role for cross-account access to external training data
resource "aws_iam_role" "extrn_data_access_role" {
  name = "${var.project_name}-extrn-data-access"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy to allow SageMaker to assume the role in data_org for external training data
resource "aws_iam_role_policy" "assume_extrn_data_org_role_policy" {
  name = "assume-extrn-data-org-role-policy"
  role = aws_iam_role.extrn_data_access_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Resource = data.terraform_remote_state.data_org.outputs.extrn_data_access_role_arn
    }]
  })
}

# Scratch space bucket
resource "aws_s3_bucket" "scratch_bucket" {
    bucket = "${var.project_name}-scratch-${var.uuid}"

    tags = {
        Name = "${var.project_name}-scratch-${var.uuid}"
        Purpose = "Temporary storage for data processing"
    }
}

# Data storage bucket
resource "aws_s3_bucket" "data_bucket" {
    bucket = "${var.project_name}-datasets-${var.uuid}"

    tags = {
        Name = "${var.project_name}-datasets-${var.uuid}"
        Purpose = "Primary storage for datasets"
    }
}

# # Model artifacts bucket
# resource "aws_s3_bucket" "model_bucket" {
#     bucket = "${var.project_name}-models"

#     tags = {
#         Name = "${var.project_name}-models"
#         Purpose = "Storage for trained models and artifacts"
#     }
# }

# # Notebook backups bucket
# resource "aws_s3_bucket" "notebook_backup_bucket" {
#     bucket = "${var.project_name}-notebook-backups"

#     tags = {
#         Name = "${var.project_name}-notebook-backups"
#         Purpose = "Backups of SageMaker notebooks"
#     }
# }

# Set lifecycle policies for scratch bucket (delete objects after 30 days)
resource "aws_s3_bucket_lifecycle_configuration" "scratch_bucket_lifecycle" {
    bucket = aws_s3_bucket.scratch_bucket.id

    rule {
        id     = "delete-after-30-days"
        status = "Enabled"

        filter {
            prefix = ""
        }

        expiration {
            days = 30
        }
    }
}

# Block public access for all buckets
resource "aws_s3_bucket_public_access_block" "block_public_access" {
    for_each = {
        scratch = aws_s3_bucket.scratch_bucket.id
        data    = aws_s3_bucket.data_bucket.id
        # model   = aws_s3_bucket.model_bucket.id
        # backup  = aws_s3_bucket.notebook_backup_bucket.id
    }

    bucket = each.value

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}
