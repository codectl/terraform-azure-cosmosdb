module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
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
    kind                = "MongoDB"
    capabilities        = ["EnableAggregationPipeline", "EnableMongo"]
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
      mongo = {
        db1 = {
          throughput = 400
          collections = {
            col1 = {
              throughput = 400
              index = {
                id = {
                  keys   = ["_id"]
                  unique = true
                }
                email = {
                  keys   = ["email"]
                  unique = true
                }
                timestamp = {
                  keys   = ["createdAt"]
                  unique = false
                }
              }
            }
          }
        }
        db2 = {
          throughput = 400
          collections = {
            col1 = {
              throughput = 400
              index = {
                id = {
                  keys   = ["_id"]
                  unique = true
                }
                compound = {
                  keys   = ["field1", "field2"]
                  unique = false
                }
              }
            }
          }
        }
      }
    }
  }
}
