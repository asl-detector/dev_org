# Create SageMaker domain
resource "aws_sagemaker_domain" "main" {
  domain_name = "${var.project_name}-domain"
  auth_mode   = "IAM"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }

  default_space_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }
}

# Add permissions to allow SageMaker to directly assume the data_org cross-account access roles
resource "aws_iam_role_policy" "sagemaker_data_lake_access" {
  name = "assume-data-lake-clean-access-role"
  role = aws_iam_role.sagemaker_execution_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      # Reference the data_org role directly instead of the dev_org role
      Resource = data.terraform_remote_state.data_org.outputs.data_lake_clean_access_role_arn
    }]
  })
}

resource "aws_iam_role_policy" "sagemaker_extrn_data_access" {
  name = "assume-extrn-data-access-role"
  role = aws_iam_role.sagemaker_execution_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      # Reference the data_org role directly instead of the dev_org role
      Resource = data.terraform_remote_state.data_org.outputs.extrn_data_access_role_arn
    }]
  })
}

# Create user profiles for data scientists
resource "aws_sagemaker_user_profile" "data_scientists" {
  for_each          = toset(var.data_scientist_users)
  domain_id         = aws_sagemaker_domain.main.id
  user_profile_name = each.value

  tags = {
    User = each.value
  }
}

# Create app for each user profile
resource "aws_sagemaker_space" "jupyter_jupyterlab" {
    space_name  = "${var.project_name}-shared-jupyterlab"
    space_display_name = "Shared JupyterLab"
    domain_id   = aws_sagemaker_domain.main.id
    
    space_settings {
        jupyter_lab_app_settings {
          default_resource_spec {
            instance_type = "ml.t3.medium"
          }
        }
    }

    ownership_settings {
      owner_user_profile_name = aws_sagemaker_user_profile.data_scientists[var.data_scientist_users[0]].user_profile_name
    }

    space_sharing_settings {
        sharing_type = "Shared"
    }
    
    # tags = var.tags
}
