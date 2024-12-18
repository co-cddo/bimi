resource "random_string" "x_cf" {
  length  = 32
  special = false
  upper   = false

  lifecycle {
    ignore_changes = [
      special,
      upper,
    ]
  }
}

locals {
  xcf = sensitive(random_string.x_cf.result)
}

data "aws_cloudfront_cache_policy" "caching_enabled" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "s3_for_caching" {
  name = "Managed-CORS-S3Origin"
}

# == functions ==

// API viewer request to set the "true-client-ip" and "true-host" headers
resource "aws_cloudfront_function" "viewer_request" {
  name    = "viewer-request-bimi-${terraform.workspace}"
  runtime = "cloudfront-js-1.0"
  comment = "viewer-request-bimi-${terraform.workspace}"
  publish = true
  code    = file("${path.module}/viewer-request/index.js")
}

// all viewer responses to set the security headers
resource "aws_cloudfront_function" "viewer_response" {
  name    = "viewer-response-bimi-${terraform.workspace}"
  runtime = "cloudfront-js-1.0"
  comment = "viewer-response-bimi-${terraform.workspace}"
  publish = true
  code    = file("${path.module}/viewer-response/index.js")
}

# == distribution ==

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.cdn_source_bucket.bucket_regional_domain_name
    origin_id   = "bimi-${terraform.workspace}-cfo"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn_source_bucket.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "bimi-${terraform.workspace}"
  default_root_object = "index.html"
  http_version        = "http2and3"

  aliases = local.use_acm ? [local.domain, "www.${local.domain}"] : []

  /*logging_config {
    include_cookies = false
    bucket          = "${local.s3_logging_bucket}.s3.amazonaws.com"
    prefix          = "cloudfront"
  }*/

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "DELETE",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "bimi-${terraform.workspace}-cfo"

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_enabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.s3_for_caching.id
    compress                 = false
    viewer_protocol_policy   = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request.arn
    }

    function_association {
      event_type   = "viewer-response"
      function_arn = aws_cloudfront_function.viewer_response.arn
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = { "Name" : local.domain }

  viewer_certificate {
    cloudfront_default_certificate = local.use_acm ? false : true
    acm_certificate_arn            = local.use_acm ? aws_acm_certificate.cdn[0].arn : null
    ssl_support_method             = local.use_acm ? "sni-only" : null
    minimum_protocol_version       = local.use_acm ? "TLSv1.2_2021" : null
  }
}

# add alias and www route53 records
# using the data.aws_route53_zone.z[0].zone_id
resource "aws_route53_record" "cdn" {
  count   = local.use_acm ? 2 : 0
  zone_id = data.aws_route53_zone.z[0].zone_id
  name    = count.index == 0 ? local.domain : "www.${local.domain}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "cdn-aaaa" {
  count   = local.use_acm ? 2 : 0
  zone_id = data.aws_route53_zone.z[0].zone_id
  name    = count.index == 0 ? local.domain : "www.${local.domain}"
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
