terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = ">= 2.6.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }

  cloud {
    organization = "CLAMS23"

    workspaces {
      name = "DEVNET-2097-Demo"
    }
  }
}

module "merge" {
  source  = "netascode/nac-merge/utils"
  version = "0.1.2"

  yaml_strings = [for file in fileset(path.module, "data/*.yaml") : file(file)]
}

module "tenant" {
  source  = "netascode/nac-tenant/aci"
  version = "0.4.2"

  for_each    = { for tenant in try(module.merge.model.apic.tenants, []) : tenant.name => tenant }
  model       = module.merge.model
  tenant_name = each.value.name
}

resource "local_sensitive_file" "defaults" {
  content  = yamlencode(module.merge.defaults)
  filename = "${path.module}/defaults.yaml"
}
