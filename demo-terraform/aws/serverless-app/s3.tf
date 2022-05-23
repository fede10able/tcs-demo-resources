
## Create random id
resource "random_string" "uniq" {
    length = 32
    special = false
    lower = true
    upper = false
}

## Create bucket
resource "aws_s3_bucket" "website" {
    bucket = "${var.resource_ride}-${random_string.uniq.result}"
    tags = local.project_tags
}

## Encrypt-Bucket (Disables for public objects)
# resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
#   bucket = aws_s3_bucket.website.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#         sse_algorithm     = "aws:kms"
#     }
#   }
# }

resource "aws_s3_bucket_versioning" "website" {
    bucket = aws_s3_bucket.website.id
    versioning_configuration {
        status = "Enabled"
    }
}



resource "aws_s3_bucket_acl" "website" {
    bucket = aws_s3_bucket.website.id
    acl    = "public-read"
}

## Upload s3 site content


module "website_content" {
    source = "hashicorp/dir/template"
    version = "1.0.2"
    base_dir = var.website_folder
}

resource "aws_s3_object" "object" {
    for_each = module.website_content.files

    bucket = aws_s3_bucket.website.bucket
    key = each.key
    content_type = each.value.content_type
    source  = each.value.source_path

    etag = each.value.digests.md5
    acl    = "public-read"

}

locals {
    config_content = templatefile(var.config_js_template, 
        {
            user_pool_id = aws_cognito_user_pool.pool.id
            user_pool_client_id = aws_cognito_user_pool_client.app_client.id
            aws_region = var.default_aws_region
            invoke_url = aws_api_gateway_stage.prod.invoke_url
        }
    )
}

resource "aws_s3_object" "config_js" {

    bucket = aws_s3_bucket.website.bucket
    key    = var.config_js_output
    content = local.config_content
    content_type = "text/javascript"
    etag = md5(local.config_content)
    acl    = "public-read"

    depends_on = [
      aws_s3_object.object          ## To avoid an accidental overwrite of config file
    ]
}


resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.website.bucket

    index_document {
        suffix = "index.html"
    }

}

output "website_url" {
    value = aws_s3_bucket_website_configuration.website.website_endpoint
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
    bucket = aws_s3_bucket.website.id
    policy = data.aws_iam_policy_document.website_policy.json
}

data "aws_iam_policy_document" "website_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.website.arn}/*",
    ]
  }
}

