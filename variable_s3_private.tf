#### variables for s3 private buckets
variable "create_s3_private_buckets" {
  type        = list(string)
  description = "List of buckets that will create"
  default     = [ "project-env-cdn-backoffice" ]
}

variable "action_policy_list" {
  type = list(string)
  default = [
    "s3:GetObject",
    "s3:GetObjectAcl"
  ]
}