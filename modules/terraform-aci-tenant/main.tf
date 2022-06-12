locals {
  defaults = lookup(var.model, "defaults", {})

  tenant = [for tenant in lookup(var.model.apic, "tenants", {}) : tenant if tenant.name == var.tenant_name][0]

  epg_map = merge([
    for ap in lookup(local.tenant, "application_profiles", []) : lookup(ap, "endpoint_groups", null) == null ? {} : {
      for epg in ap.endpoint_groups : "${ap.name}_${epg.name}" => merge(epg, { "application_profile" : "${ap.name}" })
    }
  ]...)
}

module "aci_tenant" {
  source  = "netascode/tenant/aci"
  version = ">= 0.1.0"

  name        = local.tenant.name
  description = lookup(local.tenant, "description", "")
}

module "aci_vrf" {
  source  = "netascode/vrf/aci"
  version = ">= 0.1.1"

  for_each        = { for vrf in lookup(local.tenant, "vrfs", []) : vrf.name => vrf }
  tenant          = module.aci_tenant.name
  name            = "${each.value.name}${local.defaults.apic.tenants.vrfs.name_suffix}"
  description     = lookup(each.value, "description", "")
  preferred_group = lookup(each.value, "preferred_group", local.defaults.apic.tenants.vrfs.preferred_group)
}

module "aci_bridge_domain" {
  source  = "netascode/bridge-domain/aci"
  version = ">= 0.1.0"

  for_each        = { for bd in lookup(local.tenant, "bridge_domains", []) : bd.name => bd }
  tenant          = module.aci_tenant.name
  name            = "${each.value.name}${local.defaults.apic.tenants.bridge_domains.name_suffix}"
  description     = lookup(each.value, "description", "")
  arp_flooding    = lookup(each.value, "arp_flooding", local.defaults.apic.tenants.bridge_domains.arp_flooding)
  unicast_routing = lookup(each.value, "unicast_routing", local.defaults.apic.tenants.bridge_domains.unicast_routing)
  unknown_unicast = lookup(each.value, "unknown_unicast", local.defaults.apic.tenants.bridge_domains.unknown_unicast)
  vrf             = "${each.value.vrf}${local.defaults.apic.tenants.vrfs.name_suffix}"
  subnets = [for subnet in lookup(each.value, "subnets", []) : {
    ip          = subnet.ip
    description = lookup(subnet, "description", "")
    public      = lookup(subnet, "public", local.defaults.apic.tenants.bridge_domains.subnets.public)
    shared      = lookup(subnet, "shared", local.defaults.apic.tenants.bridge_domains.subnets.shared)
  }]

  depends_on = [module.aci_vrf]
}

module "aci_application_profile" {
  source  = "netascode/application-profile/aci"
  version = ">= 0.1.0"

  for_each    = { for ap in lookup(local.tenant, "application_profiles", []) : ap.name => ap }
  tenant      = module.aci_tenant.name
  name        = "${each.value.name}${local.defaults.apic.tenants.application_profiles.name_suffix}"
  description = lookup(each.value, "description", "")
}

module "aci_endpoint_group" {
  source  = "netascode/endpoint-group/aci"
  version = ">= 0.1.0"

  for_each            = local.epg_map
  tenant              = module.aci_tenant.name
  application_profile = module.aci_application_profile[each.value.application_profile].name
  name                = "${each.value.name}${local.defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix}"
  description         = lookup(each.value, "description", "")
  preferred_group     = lookup(each.value, "preferred_group", local.defaults.apic.tenants.application_profiles.endpoint_groups.preferred_group)
  bridge_domain       = lookup(each.value, "bridge_domain", null) != null ? "${each.value.bridge_domain}${local.defaults.apic.tenants.bridge_domains.name_suffix}" : ""

  depends_on = [module.aci_bridge_domain]
}
