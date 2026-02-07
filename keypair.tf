resource "outscale_keypair" "this" {
  count = var.enable_keypair ? 1 : 0

  keypair_name = var.keypair_name != null ? var.keypair_name : "${var.project_name}-${var.environment}-keypair"
  public_key   = var.keypair_public_key
}
