provider "xenorchestra" {
  # Must be ws or wss
  url      = format("wss://%s", var.xenorchestra_hostname) # Or set XOA_URL environment variable
  username = var.xenorchestra_username                     # Or set XOA_USER environment variable
  password = var.xenorchestra_password                     # Or set XOA_PASSWORD environment variable

  # This is false by default and
  # will disable ssl verification if true.
  # This is useful if your deployment uses
  # a self signed certificate but should be
  # used sparingly!
  insecure = var.xenorchestra_insecure # Or set XOA_INSECURE environment variable to any value
}
