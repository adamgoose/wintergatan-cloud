variable "do_token" {}
variable "discord" {
  type = object({
    client_id     = string
    client_secret = string
  })
}
