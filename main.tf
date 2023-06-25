resource "hcloud_ssh_key" "default" {
  name       = var.cluster_user
  public_key = var.my_public_ssh_key
}
