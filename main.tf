terraform {
  # Add this line to satisfy the linter and enforce stability
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Define the S3 Bucket
resource "aws_s3_bucket" "resume_website" {
  bucket = "yarin-rene-cloud-resume-2026"

  tags = {
    Project     = "Cloud Resume Challenge"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 2. Configure Bucket for Static Website Hosting
resource "aws_s3_bucket_website_configuration" "resume_website_config" {
  bucket = aws_s3_bucket.resume_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 3. Disable Block Public Access (Required for static websites)
resource "aws_s3_bucket_public_access_block" "resume_website_access" {
  bucket = aws_s3_bucket.resume_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Attach Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "resume_website_policy" {
  bucket = aws_s3_bucket.resume_website.id

  depends_on = [aws_s3_bucket_public_access_block.resume_website_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.resume_website.arn}/*"
      }
    ]
  })
}

# 5. Output the Website URL
output "website_url" {
  description = "The public URL of the Cloud Resume website"
  value       = aws_s3_bucket_website_configuration.resume_website_config.website_endpoint
}
