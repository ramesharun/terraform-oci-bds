## This configuration was generated by terraform-provider-oci

resource oci_bds_bds_instance demo-bds {
  #cluster_admin_password = <<Required attribute not found in discovery>>
  #cluster_public_key = <<Required attribute not found in discovery>>
  cluster_version        = "CDH6"
  compartment_id         = var.compartment_ocid
  cluster_admin_password = var.bds_instance_cluster_admin_password
  cluster_public_key     = var.ssh_public_key

  display_name = "bds-demo"

  freeform_tags = {
    "environment" = "bds-demo"
  }

  is_cloud_sql_configured = "false"
  is_high_availability    = "true"
  is_secure               = "true"

  master_node {
    block_volume_size_in_gbs = "500"
    number_of_nodes          = "2"
    shape                    = "VM.Standard2.4"
    subnet_id                = var.subnet_ocid
  }

  network_config {
    cidr_block              = "10.0.0.0/16"
    is_nat_gateway_required = "true"
  }

  util_node {
    block_volume_size_in_gbs = "500"
    number_of_nodes          = "2"
    shape                    = "VM.Standard2.4"
    subnet_id                = var.subnet_ocid
  }

  worker_node {
    block_volume_size_in_gbs = "500"
    number_of_nodes          = "3"
    shape                    = "VM.Standard2.4"
    subnet_id                = var.subnet_ocid
  }
}