# Secure Azure Landing Zone — Build Log

**Project:** Terraform-based Hub-and-Spoke Landing Zone on Azure Free Tier
**Region:** Canada Central
**Approach:** Modular Terraform, separate state per environment (hub / dev / test / prod / policy)

---

## 1. What We're Building

A hub-and-spoke network landing zone with:
- One hub VNet (shared services + reserved Bastion subnet)
- Three isolated spoke VNets: dev, test, prod
- Bidirectional VNet peering (hub ↔ each spoke)
- One Key Vault per environment (RBAC-based access)
- One Storage Account per environment (public access denied)
- User-Assigned Managed Identity + least-privilege RBAC role per environment
- Subscription-level Azure Policy (allowed regions, required tags, Key Vault soft-delete audit, custom deny-public-storage rule)

---

## 2. Final Folder Structure

```
Project-1-Secure Azure Landing Zone/
├── modules/
│   ├── resource-group/
│   ├── hub-network/
│   ├── spoke-network/
│   ├── peering/
│   ├── keyvault/
│   ├── storage-account/
│   ├── rbac/
│   └── policy/
└── environments/
    ├── hub/          (state key: hub.terraform.tfstate)
    ├── dev/          (state key: dev.terraform.tfstate)
    ├── test/         (state key: test.terraform.tfstate)   — pending
    ├── prod/         (state key: prod.terraform.tfstate)   — pending
    └── policy/       (state key: policy.terraform.tfstate)
```

Each environment folder is a fully independent Terraform root module — its own `backend.tf`, `providers.tf`, `main.tf`, `variables.tf`, and `.tfvars` file. Environments do not share state.

---

## 3. Build Sequence (Chronological)

### Phase 1 — Remote backend
Storage account (`terraformstatesacac`) + blob container configured as the Terraform remote backend before any resources were created.

### Phase 2 — Hub network module
Built `modules/hub-network`: one VNet (`10.0.0.0/16`), two subnets (`snet-shared`, `AzureBastionSubnet`), one NSG (Bastion subnet deliberately excluded — Bastion requires its own specific NSG rule set that a generic deny-all rule would break), one deny-inbound-internet rule, one NSG-subnet association.

### Phase 3 — Variables and tfvars structure
Established the pattern: module `variables.tf` (no defaults for environment-specific values) → root `variables.tf` → `.tfvars` file supplying real values → `-var-file` flag at plan/apply time.

### Phase 4 — Spoke network module
Built `modules/spoke-network` (reusable) — same pattern as hub, minus the Bastion exception. Deployed for dev, test, and prod using different CIDR ranges (10.1.x / 10.2.x / 10.3.x).

### Phase 5 — Peering module
Built `modules/peering` — two `azurerm_virtual_network_peering` resources per spoke (hub→spoke and spoke→hub), since Azure peering is inherently one-directional per resource. No spoke-to-spoke peering (traffic isolation by design).

### Phase 6 — Refactor: single state → separate state per environment
**Original design:** one root `main.tf`, one shared `landingzone.tfstate` covering hub + all spokes.
**Problem identified:** not an enterprise-appropriate pattern — a single `terraform apply` could touch hub, dev, test, and prod simultaneously; one shared state file meant no isolation of blast radius between environments.
**Resolution:** restructured into independent `environments/hub/`, `environments/dev/`, `environments/test/`, `environments/prod/` folders, each with its own `backend.tf` (unique state file `key`), and used `terraform_remote_state` as a data source so spoke environments could read the hub's VNet ID/name without being in the same state file.
**Action taken:** destroyed the original single-state deployment, rebuilt clean under the new structure (chosen over risky in-place state migration, since no real workloads existed yet).

### Phase 7 — Key Vault module
Built `modules/keyvault` — one Key Vault per environment, `soft_delete_retention_days = 7`, `purge_protection_enabled = true`, network ACLs default-deny, later updated to `enable_rbac_authorization = true`.

### Phase 8 — RBAC module
Built `modules/rbac` — one User-Assigned Managed Identity per environment + one role assignment (`Key Vault Secrets User`) scoped only to that environment's Key Vault (least privilege, matches original guide's Step 4).

### Phase 9 — Storage Account module
Built `modules/storage-account` — one per environment, `public_network_access_enabled = false`, `min_tls_version = "TLS1_2"`, private blob container. Deliberately compliant with the custom policy built in Phase 10.

### Phase 10 — Azure Policy module
Built `modules/policy` — allowed locations, required tag enforcement, Key Vault soft-delete audit, and a custom policy definition denying public network access on storage accounts.
**Scope decision:** considered management-group scope (true enterprise pattern) but confirmed via `az account management-group list` that the account lacks `Microsoft.Management/managementGroups/read` permission — management groups are not accessible on this account. Subscription scope was confirmed as the correct and only available option, and is functionally equivalent given a single-subscription setup.
**Decision:** apply policy once, at subscription scope, in its own `environments/policy/` folder — not duplicated per environment, since subscription-scope assignments already cascade to every resource group underneath.

---

## 4. Errors Encountered and How They Were Resolved

| # | Error | Root Cause | Fix |
|---|---|---|---|
| 1 | `terraform init` run in `modules/` returned "Initialized in an empty directory" | Ran command from a folder with no root `.tf` files (modules folder, not root) | Ran `terraform init` from the actual root module folder instead |
| 2 | `Unreadable module directory` (`..\..\modules` not found) | `source` path in `module` blocks assumed root was two levels deep (`environments/landing-zone/`), but `main.tf` actually lived at the project root | Changed `source = "../../modules/..."` to `source = "./modules/..."` |
| 3 | `Duplicate variable declaration` for `location` and `tags` | Root `variables.tf` had a variable block pasted twice | Removed the duplicate blocks, kept one of each |
| 4 | Terraform kept prompting for variable values interactively | `-var-file` flag wasn't passed, or `.tfvars` file was missing required keys | Always ran `terraform plan -var-file="..."` explicitly; confirmed all declared variables had matching values in tfvars |
| 5 | Interactive prompt for `var.name` specifically | A stray `variable "name" { ... }` block (meant for the module's own `variables.tf`) had been pasted into the **root** `variables.tf` by mistake | Deleted the stray block from root; left the module's own `variables.tf` untouched |
| 6 | `Unsupported attribute` — `module.resource_group is a object... does not have an attribute named "name"` | `modules/resource-group/outputs.tf` was missing or empty — no `name` output existed to reference | Added the `name`, `id`, `location` outputs to the module |
| 7 | `Reference to undeclared module` — `module.resource-group` not found (suggested `resource_group`) | Typo: hyphen used instead of underscore when referencing the module | Corrected `module.resource-group.name` → `module.resource_group.name` |
| 8 | `data.terraform_remote_state.hub.outputs is object with no attributes` | Hub's `outputs.tf` didn't exist yet at the time hub was first applied, so no outputs were ever written into `hub.terraform.tfstate` | Added `outputs.tf` to the hub environment, re-ran `terraform apply` on hub to write the outputs into state, then re-ran spoke plans |
| 9 | `Invalid provider configuration` — azurerm requires `features {}` | New environment folders (`dev`, etc.) didn't have their own `providers.tf` — each environment is an independent root module and needs its own provider block | Added `providers.tf` (with `required_providers` + `provider "azurerm" { features {} }`) to every environment folder |
| 10 | `Reference to undeclared module` — stray `outputs.tf` in the `policy` folder referencing `module.hub_network` / `module.resource_group` | A hub-folder `outputs.tf` had been copied into the `policy` folder by mistake | Deleted the stray `outputs.tf` from `environments/policy/` |
| 11 | `The provider hashicorp/azurerm does not support resource type "azurerm_policy_assignment"` | AzureRM provider v3 split the single `azurerm_policy_assignment` resource into scope-specific types (`azurerm_subscription_policy_assignment`, `azurerm_resource_group_policy_assignment`, `azurerm_management_group_policy_assignment`) | Replaced all four `azurerm_policy_assignment` blocks with `azurerm_subscription_policy_assignment`, and `scope` argument with `subscription_id` |
| 12 | `parsing the Subscription ID: the number of segments didn't match` — expected `/subscriptions/<guid>`, got bare `<guid>` | Passed `data.azurerm_subscription.current.subscription_id` (bare GUID) where the resource actually expects the full resource path | Changed to `data.azurerm_subscription.current.id` (returns `/subscriptions/<guid>`) |

---

## 5. Key Concepts Established Along the Way

- **`for_each` over a map** (`for k, v in var.spokes`) — `k` is the map key (e.g. `"dev"`), `v` is the full value object; used to avoid repeating near-identical resource blocks for dev/test/prod.
- **Module `variables.tf` vs root `variables.tf`** — a module declares its own interface (inputs it needs); the root declares what the *user* configures via tfvars. They are separate files and should never share the same variable block.
- **tfvars only load automatically from the root module's directory**, and only if named exactly `terraform.tfvars` — any other filename (`hub.tfvars`, `dev.tfvars`, etc.) must be passed explicitly with `-var-file`.
- **`terraform_remote_state`** — how one independent environment (e.g. dev) reads values (like a VNet ID) from another environment's (hub's) state file, once they no longer share a single state.
- **Why AzureBastionSubnet has no NSG yet** — Bastion requires a specific, non-generic set of inbound/outbound rules; since Bastion isn't deployed yet, the subnet is reserved but intentionally left unprotected by the generic per-subnet NSG logic, to avoid writing untested rules for a service that isn't running.
- **Enterprise policy scope (management group vs subscription)** — management groups are the "true" enterprise pattern for governing many subscriptions at once, but require tenant-level permissions this account doesn't have; subscription scope was confirmed as the correct, fully appropriate choice for a single-subscription setup.

---

## 6. What's Left — To Finish This Project

- Duplicate the `dev/` pattern into `test/` and `prod/` (network, Key Vault, storage account, RBAC, peering)
- Apply `environments/policy/` (subscription-wide Azure Policy) — plan is clean, not yet applied
- Step 5 from the original guide: run a full `terraform plan`/`apply` across all environments, run an Azure Policy compliance scan, and write a project README documenting architecture, variables, and deployment steps

---

## 7. What's Left — Gaps vs. a Full Enterprise Landing Zone

Everything built so far follows Microsoft's hub-and-spoke pattern correctly, but a full Cloud Adoption Framework (CAF) Enterprise-Scale Landing Zone includes several pieces this project deliberately doesn't have yet — mostly because they cost money beyond Free Tier, or need permissions/subscriptions this account doesn't have. Worth tracking as known, intentional gaps rather than oversights:

| Gap | What it does | Why it's not here yet |
|---|---|---|
| **Azure Firewall (or NVA) in the hub** | Inspects and filters all traffic passing between spokes, or between a spoke and the internet | ~$900+/month — not Free Tier viable. Without it, the hub is a peering point only, not a security inspection point |
| **Route tables (UDRs) forcing traffic through the hub** | Forces spoke traffic through a central firewall/NVA instead of going direct | No firewall exists yet to route traffic *to* — this is the natural next step once a firewall is added |
| **Private Endpoints for Key Vault / Storage** | Removes public network exposure entirely, replacing the current "public access disabled + firewall rules" approach | ~$7–10/month per endpoint; current setup already denies public access, so this is a hardening upgrade, not a missing baseline |
| **Separate subscriptions per landing zone** | CAF's full pattern uses one subscription per environment (or per landing zone type — identity, connectivity, workload), not resource groups within a single subscription | Free Tier provides one subscription; resource-group-level isolation is the practical substitute |
| **Management-group-scoped policy** | Lets policy cascade across many subscriptions from one assignment | Account lacks `Microsoft.Management/managementGroups/read` permission (confirmed via CLI); not accessible on this tenant. Subscription-scope policy is the correct substitute here, and is equivalent given only one subscription exists |
| **DDoS Protection Standard** | Enhanced DDoS mitigation beyond Azure's always-on basic protection | Paid add-on (~$3,000/month for the plan), not relevant at this scale |
| **Private DNS Zones** | Custom DNS resolution for privately-linked resources (pairs with Private Endpoints) | Not needed until Private Endpoints are added |
| **Centralized logging (Log Analytics workspace in the hub + diagnostic settings on every resource)** | Single place to query logs/metrics across the whole landing zone | Not yet built — a reasonable next addition even on Free Tier, since Log Analytics has a free data allowance |
| **Azure Bastion actually deployed** | Secure RDP/SSH to VMs without public IPs | Subnet is reserved (`AzureBastionSubnet`) but the Bastion service itself hasn't been deployed — no VMs exist yet to connect to |
| **Budgets / cost alerts** | Automatic notification before Free Tier credit runs out | Not yet configured — worth setting up early given this is a Free Tier account |
| **Backup / disaster recovery** | Recovery Services vault, backup policies for VMs or storage | No stateful workloads deployed yet to back up |

### Realistic next steps, roughly in priority order
1. Set up a **cost budget/alert** on the subscription — cheapest, highest-value addition given Free Tier constraints.
2. Add a **Log Analytics workspace** in the hub with basic diagnostic settings — free tier covers small data volumes, and it's genuinely useful for troubleshooting the peering/policy setup already built.
3. If budget allows later: a **low-cost NVA or even NSG-only spoke-to-spoke deny rules** as a cheaper stand-in for Azure Firewall, to get *some* traffic inspection without the full cost.
4. Private Endpoints for Key Vault and Storage, once ready to move beyond "public access disabled" to "not reachable from the public internet at all."
5. Actual Bastion deployment + a test VM, to validate the reserved subnet and prove secure access end-to-end.
