# terragrunt-template

## Functionality
Terragrunt project with the following functionality available:

* Variables can be defined in the `environment.yaml`, `region.yaml`, `module.yaml` and `resource.yaml` files. Variables defined lower in the hierarchy override variables defined higher in the hierarchy.
* The variables will be shallow merged. Only exception will be the variable `tags`. The tags defined in multiple files will be deep merged.
* If there is a `secret.yaml` file defined, it will be decrypted with sops and the variables will be merged with the other variables. The variables defined in `secret.yaml` will be overridden by the variables defined in the other yaml files.

## About this repository
The current repository provides a minimal example using Azure Cloud. In order to adapt it to other clouds replace the sections:

```hcl
generate "provider" {
    ...
}

remote_state {
    ...
}
```


## Usage
Copy and rename the directory `env` to the environments of your project.

Example file tree for a project that has a development and production environment:

```
dev
├── environment.yaml
├── secrets.yaml
├── terragrunt.hcl
└── west_europe
    ├── region.yaml
    └── resource_group
        ├── module.yaml
        └── my_rg
            ├── resource.yaml
            └── terragrunt.hcl
prod
├── environment.yaml
├── secrets.yaml
├── terragrunt.hcl
└── west_europe
    ├── region.yaml
    └── resource_group
        ├── module.yaml
        └── my_rg
            ├── resource.yaml
            └── terragrunt.hcl
```

## Common terragrunt commands

```bash
terragrunt render-json
terragrunt run-all plan
terragrunt run-all apply
terragrunt validate-inputs
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && terragrunt init --upgrade
```