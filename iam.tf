# SageMaker Execution Role
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.project_name}-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Custom policy to allow SageMaker app creation
resource "aws_iam_policy" "sagemaker_app_creation_policy" {
  name        = "${var.project_name}-sagemaker-app-creation"
  description = "Policy for allowing SageMaker app creation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp",
          "sagemaker:DescribeApp"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_app_creation_attachment" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_app_creation_policy.arn
}

# # Custom policy for accessing specific project buckets
# resource "aws_iam_policy" "project_buckets_access" {
#   name        = "${var.project_name}-bucket-access"
#   description = "Policy for accessing project specific S3 buckets"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:ListBucket",
#           "s3:DeleteObject"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:s3:::${var.environment}-${var.project_name}-*",
#           "arn:aws:s3:::${var.environment}-${var.project_name}-*/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "project_buckets_access_attachment" {
#   role       = aws_iam_role.sagemaker_execution_role.name
#   policy_arn = aws_iam_policy.project_buckets_access.arn
# }
