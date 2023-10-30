# Changelog

## [2.1.0](https://github.com/releaseband/terraform-polaris/compare/v2.0.2...v2.1.0) (2023-10-30)


### Features

* **.github/workflows:** add release-please.yml for automated releases ([74da5ed](https://github.com/releaseband/terraform-polaris/commit/74da5ede668bbef846d4864d51117d9d23cc7163))


### Bug Fixes

* **main.tf:** modify ingress rules in kubernetes_network_policy to allow TCP traffic on port 4191 from prometheus in the monitoring namespace for better observability ([8b4e774](https://github.com/releaseband/terraform-polaris/commit/8b4e7740f8d43151478d7d05eef948f78bae0e67))
