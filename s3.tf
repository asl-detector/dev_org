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
