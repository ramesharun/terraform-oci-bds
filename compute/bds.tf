## This configuration was generated by terraform-provider-oci

resource oci_bds_bds_instance demo-bds {

  cluster_version        = "CDH6"
  compartment_id         = var.compartment_ocid
  cluster_admin_password = var.bds_instance_cluster_admin_password
  cluster_public_key = var.ssh_public_key

  display_name = var.bds_cluster_name

  freeform_tags = {
    "environment" = "bds-demo"
  }

  is_cloud_sql_configured = "false"
  is_high_availability    = "true"
  is_secure               = "true"
  //is_high_availability    = "false"
  //is_secure               = "false"

  master_node {
    block_volume_size_in_gbs = "500"
    //number_of_nodes          = "1"
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
    //number_of_nodes          = "1"
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

// Bootstrap run on Utility Node
resource "null_resource" "remote-exec" {
  depends_on = [oci_bds_bds_instance.demo-bds]
  provisioner "remote-exec" {
    connection {
      agent   = false
      timeout = "30m"
      host        = oci_core_public_ip.cm_public_ip.ip_address
      user        = "opc"
      private_key = var.ssh_private_key
    }

    inline = [
      "sudo service docker start",
      "sudo systemctl enable docker",
      "chmod +x ~/generate_tpcds_data.sh",
      "sudo docker pull iad.ocir.io/oraclebigdatadb/zeppelin-notebook-bds/zeppelin:latest",
      "sudo docker pull iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen:latest",
      "sudo docker tag iad.ocir.io/oraclebigdatadb/zeppelin-notebook-bds/zeppelin:latest zeppelin:latest",
      "sudo docker tag iad.ocir.io/oraclebigdatadb/datageneration/spark-tpcds-gen:latest spark-tpcds-gen:latest",
      "sudo docker run --cpus=4 --memory=12g  -d --network=host --rm -v /opt/:/opt/ -v /etc/hadoop:/etc/hadoop -v /etc/alternatives:/etc/alternatives -v /etc/hive:/etc/hive -v /etc/spark:/etc/spark zeppelin"
    ]
  }
}


// Bootstrap run on Master Node
resource "null_resource" "remote-exec" {
  depends_on = [oci_bds_bds_instance.demo-bds]
  provisioner "remote-exec" {
    connection {
      agent   = false
      timeout = "30m"
      host        = oci_bds_bds_instance.demo-bds.nodes[0].ip_address
      user        = "opc"
      private_key = var.ssh_private_key
    }
    inline = [
      "sudo kadmin.local -q \"add_principal -pw ${base64decode(var.bds_instance_cluster_admin_password)} opc\"",
      "sudo kadmin.local -q \"xst -norandkey -k opc.keytab opc\"",
      "sudo chown opc:opc opc.keytab",
      "dcli -f opc.keytab -d opc.keytab",
    ]
  }


data "oci_core_private_ips" "test_private_ips_by_ip_address" {
  #Optional
  ip_address = substr(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url, 8, length(oci_bds_bds_instance.demo-bds.cluster_details[0].cloudera_manager_url) - 13)
  subnet_id  = var.subnet_ocid
}

resource "oci_core_public_ip" "cm_public_ip" {
  depends_on = [oci_bds_bds_instance.demo-bds]
  #Required
  compartment_id = var.compartment_ocid
  lifetime       = "EPHEMERAL"

  #Optional
  display_name = "BDS Demo Cloudera Manager IP"
  freeform_tags = {
    "environment" = "bds-demo"
  }
  private_ip_id = data.oci_core_private_ips.test_private_ips_by_ip_address.private_ips[0].id
}