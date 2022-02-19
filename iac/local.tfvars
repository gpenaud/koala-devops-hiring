
# ==============================================================================
# generic variables
# ==============================================================================

region              = "eu-west-1"
tfstate_bucket_name = "kdh-tfstates"
env                 = "local"
owner               = "gpenaud"
project             = "kdh"

# ==============================================================================
# network-specific variables
# ==============================================================================

network_tfstate_bucket_path = "network"
network_vpc_cidr            = "10.100.0.0/16"
network_public_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]

# ==============================================================================
# database-specific variables
# ==============================================================================

database_username = "koala_aws"
database_password = "koala_pass"
database_users = [
  "dba-one",
  "dba-two"
]
