
resource "random_string" "bucket_suffix" {
    upper = false
    special = false
    length = 32
}

resource "aws_s3_bucket" "bucket" {
    bucket = "${replace(local.user_mail,"@","-")}-${random_string.bucket_suffix.result}"

    tags = local.default_tags
}

resource "aws_s3_bucket_acl" "bucket" {
    bucket = aws_s3_bucket.bucket.id
    acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket" {
    bucket = aws_s3_bucket.bucket.id

    block_public_acls   = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

# resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
#     bucket = aws_s3_bucket.bucket.bucket

#     rule {
#         apply_server_side_encryption_by_default {
#             sse_algorithm     = "aws:kms"
#         }
#     }
# }
