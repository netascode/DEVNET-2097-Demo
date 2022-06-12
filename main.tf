terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = ">= 2.1.0"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.1.1"
    }
  }

  cloud {
    organization = "CLUS22"

    workspaces {
      name = "DEVNET-2097-DEMO"
    }
  }
}

locals {
  model = yamldecode(data.utils_yaml_merge.model.output)
}

data "utils_yaml_merge" "model" {
  input = concat([for file in fileset(path.module, "data/*.yaml") : file(file)], [file("${path.module}/defaults/defaults.yaml")])
}

module "tenant" {
  source = "./modules/terraform-aci-tenant"

  for_each    = toset([for tenant in lookup(local.model.apic, "tenants", {}) : tenant.name])
  model       = local.model
  tenant_name = each.value
}
