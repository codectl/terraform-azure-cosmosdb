module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "germanywestcentral"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "cosmosdb" {
  source  = "codectl/cosmosdb/azure"
  version = "~> 1.0"

  account = {
    name                = module.naming.cosmosdb_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    kind                = "GlobalDocumentDB"

    geo_location = {
      francecentral = {
        location          = "francecentral"
        failover_priority = 0
      }
    }

    consistency_policy = {
      consistency_level = "Session"
    }

    databases = {
      sql = {
        db1 = {
          throughput = 400
          containers = {
            sqlc1 = {
              throughput          = 400
              partition_key_paths = ["/definition/idlong"]
              index_policy = {
                indexing_mode  = "consistent"
                included_paths = ["/*"]
              }
              unique_key = {
                key1 = {
                  paths = ["/definition/idlong", "/definition/idshort"]
                }
                key2 = {
                  paths = ["/definition/type", "/definition/category"]
                }
              }
            }
          }
        }
      }
    }
  }
}
