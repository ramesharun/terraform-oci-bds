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
resource "null_resource" "remote-exec" {
  connection {
    agent       = false
    timeout     = "1m"
    host        = substr(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url, 8, length(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url) - 13)
    user        = "opc"
    private_key = var.ssh_private_key
  }
  inline = [
    "sudo service docker start"
    /* "sudo systemctl enable docker",
      "sudo docker pull iad.ocir.io/oraclebigdatadb/zeppelin-notebook-bds/zeppelin:latest",
      "sudo docker tag iad.ocir.io/oraclebigdatadb/zeppelin-notebook-bds/zeppelin:latest zeppelin:latest",
      "sudo docker run --cpus=4 --memory=12g  -d --network=host --rm -v /opt/:/opt/ -v /etc/hadoop:/etc/hadoop -v /etc/alternatives:/etc/alternatives -v /etc/hive:/etc/hive -v /etc/spark:/etc/spark zeppelin", */
  ]
}

resource "oci_core_public_ip" "cm_public_ip" {
  #Required
  compartment_id = var.compartment_ocid
  lifetime       = "Ephemeral"
  #Optional
  display_name = "bds-demo-cm_public_ip"
  freeform_tags = {
    "environment" = "bds-demo"
  }
  private_ip_id = substr(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url, 8, length(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url) - 13)
}