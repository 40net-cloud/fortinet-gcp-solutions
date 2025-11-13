prefix = "fgt-nccstar"
region = "europe-west8"
labels = {
  owner : "johndoe"
  project: "ncc_star_demo"
}

spokes = {
    spoke1 = {
      ip_cidr_range = "10.10.201.0/24"
    },
    spoke2 = {
      ip_cidr_range = "10.10.202.0/24"
    }
    spoke3 = {
      ip_cidr_range = "10.10.203.0/24"
      region = "europe-central2"
    }
}