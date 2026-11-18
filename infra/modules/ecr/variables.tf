variable "repository_name" {
  description = "Name of the ECR repository for application images."
  type        = string
}

variable "force_delete" {
  description = "Allow nonempty repository deletion only during intentional teardown."
  type        = bool
  default     = false
}

variable "max_image_count" {
  description = "Number of most recent images to retain; older images are expired."
  type        = number
  default     = 20

  validation {
    condition     = var.max_image_count >= 5
    error_message = "Retain at least 5 images so recent releases remain available for rollback."
  }
}

variable "untagged_image_expiry_days" {
  description = "Days after which untagged images are expired."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_expiry_days >= 1
    error_message = "Untagged image expiry must be at least 1 day."
  }
}
