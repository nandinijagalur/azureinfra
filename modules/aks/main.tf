# modules/aks/main.tf

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.dns_prefix

  # Control-plane identity — separate concern from pod/workload identity.
  # System-assigned is standard here: it only manages AKS's own resources
  # (LB, managed disks), doesn't need to survive cluster deletion.
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "system"
    node_count     = 1                    # single node — free-tier posture
    vm_size        = "Standard_D2ps_v5"        # cheapest burstable size
    vnet_subnet_id = var.aks_subnet_id
    tags           = var.tags   # ← propagates tags down to the VMSS Azure creates
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"        # avoids burning VNet IPs per pod
    network_policy      = "azure"
  }

  # Enables Workload Identity Federation — lets K8s service accounts
  # federate to your existing user-assigned identity (id-dev-app)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  tags = var.tags
}

# Lets AKS pull images from ACR without admin credentials/secrets
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

# Federates a Kubernetes service account to your existing rbac-module identity,
# so pods can authenticate to Key Vault/DB as id-dev-app — no secrets in pods.
resource "azurerm_federated_identity_credential" "workload" {
  name                = "fed-${var.workload_identity_name}"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  parent_id           = var.workload_identity_id       # = module.rbac.identity_id
  subject             = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"
}