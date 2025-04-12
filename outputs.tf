output "sagemaker_domain_id" {
  description = "The ID of the SageMaker domain"
  value       = aws_sagemaker_domain.main.id
}

output "sagemaker_domain_url" {
  description = "The URL of the SageMaker domain"
  value       = aws_sagemaker_domain.main.url
}

output "sagemaker_user_profiles" {
  description = "The user profiles created in the SageMaker domain"
  value       = [for user in aws_sagemaker_user_profile.data_scientists : user.user_profile_name]
}

output "s3_bucket_names" {
  description = "The names of the S3 buckets created"
  value = {
    scratch  = aws_s3_bucket.scratch_bucket.bucket
    datasets = aws_s3_bucket.data_bucket.bucket
    # models   = aws_s3_bucket.model_bucket.bucket
    # backups  = aws_s3_bucket.notebook_backup_bucket.bucket
  }
}

output "sagemaker_role_arn" {
  description = "The ARN of the SageMaker execution role"
  value       = aws_iam_role.sagemaker_execution_role.arn
}
