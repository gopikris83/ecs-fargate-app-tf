module "network" {
  source   = "./modules/vpc/"
  vpc_cidr = "172.31.0.0/16"
}
