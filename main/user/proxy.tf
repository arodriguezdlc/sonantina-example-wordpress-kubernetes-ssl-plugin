variable "nginx_image" {}
variable "nginx_replicas" {}
variable "nginx_cpu_request" {}
variable "nginx_cpu_limit" {}
variable "nginx_ram_request" {}
variable "nginx_ram_limit" {}

module "proxy" {
  user_component  = var.user_component
  backend_service = module.wordpress.service_name

  image = var.nginx_image

  replicas    = var.nginx_replicas
  cpu_request = var.nginx_cpu_request
  cpu_limit   = var.nginx_cpu_limit
  ram_request = var.nginx_ram_request
  ram_limit   = var.nginx_ram_limit

  source = "../../../modules/proxy"
}