
data "sops_file" "secrets" {
  source_file = "../secrets.yaml.enc"
  input_type = "yaml"
}