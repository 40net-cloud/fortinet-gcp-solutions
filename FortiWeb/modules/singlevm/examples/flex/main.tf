module "fwb" {
  source     = "../.."
  zone       = "us-central1-b"
  subnets    = ["external", "internal"]
  flex_token = "49AFA2E6EE81D4CCB121"
  image = {
    version = "7.4.4"
  }
  #"fwb-743-byol-05292024-001-w-license"
  prefix     = "demo-fwb-flex"
}