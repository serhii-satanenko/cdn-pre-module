# module "origin_label" {
#   source  = "cloudposse/label/null"
#   version = "0.25.0"
#   attributes = ["origin"]
#   context = module.this.context
# }

resource "aws_cloudfront_origin_access_identity" "s3_origin_access_identity" {
  # count = module.this.enabled ? 1 : 0
  # comment = module.origin_label.id
  comment = "Access identity for S3 bucket"
}

resource "aws_cloudfront_distribution" "this"{
  # count = module.this.enabled ? 1 : 0
  enabled             = var.distribution_enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
	price_class         = var.price_class
	comment             = var.comment
  http_version        = var.http_version
  aliases             = var.aliases
  # web_acl_id          = var.web_acl_id
  web_acl_id          = "arn:aws:wafv2:us-east-1:160719357022:global/webacl/my-web-acl/621df3a5-6be5-4f47-b1fd-2cb1d5880402"

	restrictions {
		geo_restriction {
			restriction_type = var.geo_restriction_type
			locations        = var.geo_restriction_locations
		}
	}

  # dynamic "logging_config" {
  #   for_each = var.logging_enabled ? ["true"] : []
  #   content {
  #     include_cookies = var.log_include_cookies
  #     bucket          = length(var.log_bucket_fqdn) > 0 ? var.log_bucket_fqdn : module.logs.bucket_domain_name
  #     prefix          = var.log_prefix
  #   }
  # }

  dynamic "custom_error_response" {
		for_each = var.custom_error_response
		content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code = custom_error_response.value.error_code
      response_code = custom_error_response.value.response_code
      response_page_path = custom_error_response.value.response_page_path
		}
	}

	viewer_certificate {
		cloudfront_default_certificate = var.viewer_certificate
	}

	dynamic "origin" {
    for_each = var.custom_origins
    content {
      domain_name         = origin.value.domain_name
      origin_id           = origin.value.origin_id
      origin_path         = lookup(origin.value, "origin_path", "")
      connection_attempts = try(origin.value.connection_attempts, 3)
      connection_timeout  = try(origin.value.connection_timeout, 10)
			dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config == true ? [true] : []
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.s3_origin_access_identity.cloudfront_access_identity_path
        }
      }

      dynamic "custom_origin_config" {
        for_each = length(origin.value.custom_origin_config) == 1 ? [origin.value.custom_origin_config] : []
        content {
          http_port                 = try(custom_origin_config.value[0]["http_port"], 80)
          https_port                = try(custom_origin_config.value[0]["https_port"], 443)
          origin_protocol_policy    = try(custom_origin_config.value[0]["origin_protocol_policy"], "https-only")
          origin_ssl_protocols      = try(custom_origin_config.value[0]["origin_ssl_protocols"], ["TLSv1.2"])
          origin_read_timeout       = try(custom_origin_config.value[0]["origin_read_timeout"], 30)
          origin_keepalive_timeout  = try(custom_origin_config.value[0]["origin_keepalive_timeout"], 5)
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = var.default_target_origin_id
    compress                   = var.compress
    response_headers_policy_id = var.response_headers_policy_id
    viewer_protocol_policy     = var.viewer_protocol_policy
    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id

    dynamic "forwarded_values" {
      for_each = try(coalesce(var.cache_policy_id), null) == null && try(coalesce(var.origin_request_policy_id), null) == null ? [true] : []
      content {
        headers = var.forward_headers
        query_string = var.forward_query_string
        cookies {
          forward           = var.forward_cookies
          whitelisted_names = var.forward_cookies_whitelisted_names
        }
      }
    }
    default_ttl             = var.default_ttl
    min_ttl                 = var.min_ttl
    max_ttl                 = var.max_ttl
    realtime_log_config_arn = var.realtime_log_config_arn
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache

    content {
      path_pattern               = ordered_cache_behavior.value.path_pattern
      target_origin_id           = ordered_cache_behavior.value.target_origin_id
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ordered_cache_behavior.value.cached_methods
      compress                   = ordered_cache_behavior.value.compress
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy
      trusted_signers            = var.trusted_signers # ?????
      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      dynamic "forwarded_values" {
        for_each = try(coalesce(ordered_cache_behavior.value.cache_policy_id), null) == null && try(coalesce(ordered_cache_behavior.value.origin_request_policy_id), null) == null ? [true] : []
        
        content {
          query_string = ordered_cache_behavior.value.forward_query_string
          headers      = ordered_cache_behavior.value.forward_header_values

          cookies {
            forward = ordered_cache_behavior.value.forward_cookies
          }
        }
      }
      default_ttl            = ordered_cache_behavior.value.default_ttl
      min_ttl                = ordered_cache_behavior.value.min_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
      smooth_streaming       = ordered_cache_behavior.value.smooth_streaming
    }
  }
}