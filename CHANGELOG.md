# Changelog

## [2.3.2](https://github.com/releaseband/terraform-polaris/compare/v2.3.1...v2.3.2) (2024-07-24)


### Bug Fixes

* vault policy path ([7c89b84](https://github.com/releaseband/terraform-polaris/commit/7c89b8460125c6052ba894cd8ee1a0699b3861c4))

## [2.3.1](https://github.com/releaseband/terraform-polaris/compare/v2.3.0...v2.3.1) (2024-06-11)


### Bug Fixes

* commented deployment oauth2 and moved creation vault secret to main.rf ([20bf9ae](https://github.com/releaseband/terraform-polaris/commit/20bf9ae36b60774342ad0d3334b9f066a8c84f5e))

## [2.3.0](https://github.com/releaseband/terraform-polaris/compare/v2.2.2...v2.3.0) (2024-06-07)


### Features

* add oauth2 service ([4ba9c28](https://github.com/releaseband/terraform-polaris/commit/4ba9c285736abfed133bcbd882d8530a6ba1c18b))

## [2.2.2](https://github.com/releaseband/terraform-polaris/compare/v2.2.1...v2.2.2) (2024-04-08)


### Bug Fixes

* updated README and formatted main.tf ([426488b](https://github.com/releaseband/terraform-polaris/commit/426488b68b61aa8fcaf75c1705ddf05bd297dc48))

## [2.2.1](https://github.com/releaseband/terraform-polaris/compare/v2.2.0...v2.2.1) (2024-04-08)


### Bug Fixes

* changed helmchart url to nexus ([a52ca32](https://github.com/releaseband/terraform-polaris/commit/a52ca32e855bbb4e9f1d99e101ca7c9456dec438))

## [2.2.0](https://github.com/releaseband/terraform-polaris/compare/v2.1.0...v2.2.0) (2024-04-05)


### Features

* added kustomize ([d2b01b8](https://github.com/releaseband/terraform-polaris/commit/d2b01b85dc093e8d81f5b0f87a3680b988779408))
* added new containers resources variables ([d307b79](https://github.com/releaseband/terraform-polaris/commit/d307b794fb2d22b3c09ecb2c2fcdd5567ae039cf))
* **main.tf:** added custom variables for helm chart ([c1c139f](https://github.com/releaseband/terraform-polaris/commit/c1c139f7c69deb8f27905b08e004b225e395c825))


### Bug Fixes

* formated ([b7e789f](https://github.com/releaseband/terraform-polaris/commit/b7e789f3a5f58af60c7f715356ece910cbcf2737))

## [2.1.0](https://github.com/releaseband/terraform-polaris/compare/v2.0.2...v2.1.0) (2023-10-30)


### Features

* **.github/workflows:** add release-please.yml for automated releases ([74da5ed](https://github.com/releaseband/terraform-polaris/commit/74da5ede668bbef846d4864d51117d9d23cc7163))


### Bug Fixes

* **main.tf:** modify ingress rules in kubernetes_network_policy to allow TCP traffic on port 4191 from prometheus in the monitoring namespace for better observability ([8b4e774](https://github.com/releaseband/terraform-polaris/commit/8b4e7740f8d43151478d7d05eef948f78bae0e67))
