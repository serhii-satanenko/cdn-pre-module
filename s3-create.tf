resource "aws_s3_bucket" "this" {
  for_each = toset(var.create_s3_private_buckets)
  bucket = each.key

  tags = {
    Name = each.key
  }
}

resource "aws_s3_bucket_acl" "this" {
  for_each = toset(var.create_s3_private_buckets)
  bucket = each.key
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = toset(var.create_s3_private_buckets)
  bucket = each.key

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "this" {
  for_each = aws_s3_bucket.this

  version = "2008-10-17"
  statement {
    sid = "1"
    effect = "Allow"
    actions = var.action_policy_list
    resources = ["${each.value.arn}/*"]
    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  policy = data.aws_iam_policy_document.this[each.key].json
}