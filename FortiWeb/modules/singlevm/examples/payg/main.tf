module "fwb" {
  source     = "../.."
  zone       = "us-central1-b"
  subnets    = ["external", "internal"]
  image_name = "fwb-743-payg-05292024-001-w-license"
  prefix     = "demo-fwb-flex"
}