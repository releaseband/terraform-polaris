# Configure AzureAD Application for OAUTH2
data "azuread_client_config" "current" {}
# Crossplane: provider-azuread to register new Application OAUTH2
resource "kubernetes_manifest" "azuread_application_oauth2" {
  manifest = yamldecode(<<YAML
apiVersion: applications.azuread.upbound.io/v1beta1
kind: Application
metadata:
  annotations:
    meta.upbound.io/id: applications/v1beta1/application
  labels:
    testing.upbound.io/name: ${local.azure_appname}
  name: ${local.azure_appname}
spec:
  forProvider:
    displayName: ${local.azure_appname}
    groupMembershipClaims:
      - ApplicationGroup
    requiredResourceAccess:
      - resourceAppId: ${var.oauth2_proxy_required_resource_access_MicrosoftGraph}
        resourceAccess:
          - id: ${var.oauth2_proxy_resource_access_GroupReadAll}
            type: "Scope"
          - id: ${var.oauth2_proxy_resource_access_DirectoryReadAll}
            type: "Scope"
    api:
      - requestedAccessTokenVersion: 2
    web:
      - redirectUris: 
        - "${local.redirectUrl}"
  providerConfigRef:
    name: provider-azuread-config
YAML
  )
  field_manager {
    force_conflicts = "true"
  }
}

# Crossplane: provider-azuread create new secret for Application OAUTH2
# writeConnectionSecretToRef - write in ns polaris-viz k8s secrets 
resource "kubernetes_manifest" "azuread_application_secret_oauth2" {
  depends_on = [kubernetes_manifest.azuread_application_oauth2]
  manifest = yamldecode(<<YAML
apiVersion: applications.azuread.upbound.io/v1beta1
kind: Password
metadata:
  annotations:
    meta.upbound.io/id: applications/v1beta1/password
  labels:
    testing.upbound.io/name: ${local.azure_appname}
  name: ${local.appname}-secret
spec:
  forProvider:
    displayName: "${local.appname}-secret"
    applicationObjectIdSelector:
      matchLabels:
        testing.upbound.io/name: ${local.azure_appname}
    endDateRelative: "87600h"
  providerConfigRef:
    name: provider-azuread-config
  writeConnectionSecretToRef:
    name: ${local.appname}
    namespace: ${kubernetes_namespace.main.metadata[0].name}
YAML
  )
  field_manager {
    force_conflicts = "true"
  }
}

resource "kubernetes_manifest" "azuread_application_service_principal" {
  manifest = yamldecode(<<YAML
apiVersion: serviceprincipals.azuread.upbound.io/v1beta1
kind: Principal
metadata:
  annotations:
    meta.upbound.io/id: serviceprincipals/v1beta1/principal
  labels:
    testing.upbound.io/name: ${local.azure_appname}-principal
  name: ${local.appname}-sp
spec:
  forProvider:
    applicationIdSelector:
      matchLabels:
        testing.upbound.io/name: ${local.azure_appname}
    useExisting: true
    appRoleAssignmentRequired: true
  providerConfigRef:
    name: provider-azuread-config
YAML
  )
  field_manager {
    force_conflicts = "true"
  }
}

resource "kubernetes_manifest" "azuread_application_role_assign" {
  manifest = yamldecode(<<YAML
apiVersion: app.azuread.upbound.io/v1beta1
kind: RoleAssignment
metadata:
  annotations:
    meta.upbound.io/example-id: app/v1beta1/roleassignment
  labels:
    testing.upbound.io/name: ${local.azure_appname}
  name: ${local.appname}-role-assign
spec:
  forProvider:
    appRoleId: "00000000-0000-0000-0000-000000000000"
    principalObjectId: "${var.oauth2_proxy_allowed_group}"
    resourceObjectIdSelector:
      matchLabels:
        testing.upbound.io/name: ${local.azure_appname}-principal
  providerConfigRef:
    name: provider-azuread-config
YAML
  )
  field_manager {
    force_conflicts = "true"
  }
}

