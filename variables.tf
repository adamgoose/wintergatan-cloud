variable "do_token" {
  type = string
}
variable "discord_bot_token" {
  type = string
}
variable "discord" {
  type = object({
    client_id     = string
    client_secret = string
  })
}
variable "cloudflare_token" {
  type = string
}
variable "cloudflare_key" {
  type = string
}
