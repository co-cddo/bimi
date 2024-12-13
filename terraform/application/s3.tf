resource "random_string" "random" {
  length  = 12
  special = false
  upper   = false

  lifecycle {
    ignore_changes = [
      special,
      upper,
    ]
  }
}

# ========== Cloudfront S3 Origin (assets) ==========

resource "aws_s3_bucket" "cdn_source_bucket" {
  bucket = "bimi-${terraform.workspace}-${random_string.random.result}"
  tags = {
    "Name" : "bimi-${terraform.workspace}-${random_string.random.result}"
  }
}

resource "aws_s3_bucket_versioning" "cdn_source_bucket" {
  bucket = aws_s3_bucket.cdn_source_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_cloudfront_origin_access_identity" "cdn_source_bucket" {
  comment = "bimi"
}

data "aws_iam_policy_document" "cdn_source_bucket_policy" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "${aws_s3_bucket.cdn_source_bucket.arn}/*",
      aws_s3_bucket.cdn_source_bucket.arn
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.cdn_source_bucket.iam_arn
      ]
    }
  }

  statement {
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.cdn_source_bucket.arn}/*",
      aws_s3_bucket.cdn_source_bucket.arn
    ]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_source_bucket" {
  bucket = aws_s3_bucket.cdn_source_bucket.id
  policy = data.aws_iam_policy_document.cdn_source_bucket_policy.json
}

locals {
  asset_directory = "${path.module}/../../assets/"
  mime_types = {
    "svg"  = "image/svg+xml"
    "pem"  = "application/x-pem-file"
    "html" = "text/html"
    "css"  = "text/css"
    "txt"  = "text/plain"
  }
  files = fileset(local.asset_directory, "*") # Adjust directory path and pattern as needed
}

resource "aws_s3_object" "folder_upload" {
  for_each     = { for file in local.files : file => file }
  bucket       = aws_s3_bucket.cdn_source_bucket.bucket
  key          = regexall("[^\\\\/]+$+$", each.value)[0]
  source       = "${local.asset_directory}${each.value}"
  etag         = filemd5("${local.asset_directory}${each.value}")
  content_type = lookup(local.mime_types, regexall("[^.]+$", each.value)[0], "binary/octet-stream")
}
