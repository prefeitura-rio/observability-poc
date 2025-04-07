locals {
  host_without_dot = replace(var.host, ".", "-")
}
