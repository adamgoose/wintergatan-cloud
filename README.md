# Wintergatan Cloud

This repository contains configuration and cloud insfrastructure for
Wintergatan's cloud analytics.

## Available Services

- Ingress Controller: https://traefik.wintergatan.enge.me
- Prometheus: https://prom.wintergatan.enge.me
- Grafana: https://grafana.wintergatan.enge.me

## Requirements

In order to contribute to this infrastructure, you'll need to get a few things
installed:

- [Terraform]
- [Terraform Kustomize Provider][TerraformKustomize]
- [Git-Secret]

## Managing Secrets

Secrets in this repo are comprised of Terraform state and Terraform variables.
[Git-Secret] is used to encrypt and decrypt the values for local development. In
order to decrypt the secrets, you'll need to have your public pgp key added to
the trusted keychain. Submit an issue with your pgp key and I'll add you if I
like you.

```bash
# Clone the repository
git clone https://github.com/adamgoose/wintergatan-cloud.git
cd wintergatan-cloud

# Decrypt the secrets
git secret reveal

# Modify terraform, apply changes, dev-loop, etc...

# Encrypt the secrets
git secret hide

# Commit and push your changes
git commit -am 'A super awesome change'
git push origin master
```

[Terraform]: https://www.terraform.io/
[TerraformKustomize]: https://github.com/kbst/terraform-provider-kustomize
[Git-Secret]: https://git-secret.io/