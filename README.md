# Cisco Live Amsterdam 2023 DEVNET-2097 Demo

## Setup

Install [Terraform](https://www.terraform.io/downloads), and the following two Python tools:

- [iac-validate](https://github.com/netascode/iac-validate)
- [iac-test](https://github.com/netascode/iac-test)

```shell
pip install -r requirements.txt
```

Set environment variables pointing to APIC:

```shell
export ACI_USERNAME=admin
export ACI_PASSWORD=Cisco123
export ACI_URL=https://10.1.1.1
```

Update the `cloud` block within the `terraform` configuration in `main.tf` to point to your Terraform Cloud Organization and Workspace:

```terraform
terraform {
  cloud {
    organization = "CLUS22"

    workspaces {
      name = "DEVNET-2097-DEMO"
    }
  }
}
```

Or remove the `cloud` block completely to revert to local state storage.

## Initialization

```shell
terraform init
```

## Pre-Change Validation

```shell
iac-validate ./data/
```

## Terraform Plan/Apply

```shell
terraform apply
```

## Testing

```shell
iac-test --data ./data --data ./defaults.yaml --templates ./tests/templates --output ./tests/results/aci
```
