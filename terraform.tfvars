# Application Definition 
app_name        = "assessment-8" #do NOT enter any spaces
app_environment = "dev"       # Dev, Test, Prod, etc
app_domain      = "devcloud.com"
app_project     = "santu0908-365206"
app_node_count  = 2

# GCP Settings
gcp_region_1  = "europe-west2"
gcp_zone_1    = "europe-west2-b"
authentication_file = "key.json"

# GCP Netwok
private_subnet_cidr_1 = "10.1.0.0/16"

#Service account information
app_service_account="projectnumber-compute@devolper.gservicesaccounts.com"