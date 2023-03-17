variable "custom_origins" {
  type = list(object({
    domain_name         = string
    origin_id           = string
    origin_path         = string
    connection_attempts = number
    connection_timeout  = number
    s3_origin_config    =  bool
    custom_headers      = list(object({
      name  = string
      value = string
    }))
    custom_origin_config = list(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_read_timeout      = number
      origin_keepalive_timeout = number
    }))
  }))
  default = [ 
    {
      domain_name           = "project-env-cdn-backoffice.s3.eu-central-1.amazonaws.com"
      origin_id             = "project-env-cdn-backoffice"
      origin_path           = ""
      connection_attempts   = 2
      connection_timeout    = 5
      s3_origin_config      = true
      custom_headers        = []
      custom_origin_config  = []
    },
    {
      domain_name           = "test-crmdata-dev01-cloud-static.s3.eu-central-1.amazonaws.com"
      origin_id             = "test-crmdata-dev01-cloud-static"
      origin_path           = ""
      connection_attempts   = 3
      connection_timeout    = 10
      s3_origin_config      = false
      custom_headers        = []
      custom_origin_config  = []
    },
    {
      domain_name           = "MAIN-ALB-1049649966.eu-central-1.elb.amazonaws.com"
      origin_id             = "backoffice-alb"
      origin_path           = ""
      connection_attempts   = 3
      connection_timeout    = 10
      s3_origin_config      = false
      custom_headers        = []
      custom_origin_config  = [{
          http_port                 = 80
          https_port                = 443
          origin_protocol_policy    = "http-only"
          origin_ssl_protocols      = ["TLSv1.2"]
          connection_attempts       = 3
          connection_timeout        = 10
          origin_read_timeout       = 30
          origin_keepalive_timeout  = 30
      }]
    } 
  ]
}