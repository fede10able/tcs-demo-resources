
variable "rest_api_id" {
    type = string
}
 
variable "path_part" {
    type = string
}

variable "parent_id" {
    type = string
    default = null
}

variable "enable_cors" {
    type = bool
    default = false
}

variable "allow_header" {
    type = string
    default = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
}

variable "allow_method" {
    type = string
    default = "'GET,OPTIONS,POST,DELETE,PUT'"
}

variable "allow_origin" {
    type = string
    default = "'*'"
}
