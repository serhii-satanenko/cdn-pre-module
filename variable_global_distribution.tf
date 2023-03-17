#### GLOBAL variables for aws_cloudfront_distribution ####
variable "distribution_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` if you want CloudFront to begin processing requests as soon as the distribution is created, or to false if you do not want CloudFront to begin processing requests after the distribution is created."
}

variable "dns_aliases_enabled" { #####
  type        = bool
  default     = true
  description = "Set to false to prevent dns records for aliases from being created"
}

variable "aliases" {
  type        = list(string)
  default     = []
  description = "List of aliases. CAUTION! Names MUSTN'T contain trailing `.`"
}

variable "web_acl_id" {
  type        = string
  description = "ARN of the AWS WAF web ACL that is associated with the distribution"
  default     = ""
}

variable "is_ipv6_enabled" {
  type        = bool
  default     = true
  description = "State of CloudFront IPv6"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Object that CloudFront return when requests the root URL"
}

variable "comment" {
  type        = string
  default     = "Managed by Terraform. Owner Serhii Satanenko"
  description = "Comment for the origin access identity"
}

variable "price_class" {
  type = string
  default = "PriceClass_100"
	description = "Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
}

variable "http_version" {
  type        = string
  default     = "http2and3"
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3."
}

variable "geo_restriction_type" {
  # e.g. "whitelist"
  type        = string
  default     = "none"
  description = "Method that use to restrict distribution of your content by country: `none`, `whitelist`, or `blacklist`"
}

variable "geo_restriction_locations" {
  type = list(string)

  # e.g. ["US", "CA", "GB", "DE", "UA"]
  default     = []
  description = "List of country codes for which CloudFront either to distribute content (whitelist) or not distribute your content (blacklist)"
}

variable "viewer_certificate" {
  type = bool
  default = true
}

variable "custom_error_response" {
  type = map(object({
    error_caching_min_ttl = number 
    error_code            = number
    response_code         = number
    response_page_path    = string
  }))
	description = "map of one or more custom error response element maps"
  default = {
    "400" = {
      error_caching_min_ttl = 10
      error_code = 400
      response_code = 400
      response_page_path = "/index.html"
    }
    "403" = {
      error_caching_min_ttl = 10
      error_code = 403
      response_code = 403
      response_page_path = "/index.html"
    }
    "404" = {
      error_caching_min_ttl = 10
      error_code = 404
      response_code = 404
      response_page_path = "/index.html"
    }
  }
}