
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