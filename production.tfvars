
# ==============================================================================
# generic variables
# ==============================================================================

region              = "eu-west-1"
tfstate_bucket_name = "kdh-tfstates"
environment         = "production"
owner               = "gpenaud"
project             = "kdh"

# ==============================================================================
# database-specific variables
# ==============================================================================

database_username = "koala_aws"
database_password = "koala_pass"
database_users = [
  "dba-one",
  "dba-two"
]

# ==============================================================================
# iam-specific variables
# ==============================================================================

iam_developers = [
  "guillaume",
  "cyril",
  "vincent"
]

iam_dbas = [
  "cyril"
]

iam_data_analysts = [
  "vincent"
]
