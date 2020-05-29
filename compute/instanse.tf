resource oci_core_instance bds-demo-egde {
  availability_domain = data.oci_identity_availability_domain.US-ASHBURN-AD-1.name
  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
  }
  compartment_id = var.compartment_ocid
  create_vnic_details {
    assign_public_ip       = "true"
    display_name           = "bds-demo-egde"
    hostname_label         = "bds-demo-egde"
    nsg_ids                = []
    skip_source_dest_check = "false"
    //subnet_id              = oci_core_subnet.export_bds.id
    subnet_id = var.subnet_ocid
  }

  display_name = "bds-demo-egde"
  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = "true"
    is_pv_encryption_in_transit_enabled = "true"
    network_type                        = "VFIO"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }

  metadata = {
    "ssh_authorized_keys" = var.ssh_public_key
  }
  #preserve_boot_volume = <<Optional value not found in discovery>>
  shape = "VM.Standard2.1"

  shape_config {
    ocpus = "1"
  }

  source_details {
    source_id   = var.vm_image_id[var.region]
    source_type = "image"
  }
  state = "RUNNING"

  freeform_tags = {
    "environment" = "bds-demo"
  }


  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = file("./userdata/privateKey")
    }
    source      = "./userdata/bootstrap.sh"
    destination = "~/bootstrap.sh"
  }
  provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = file("./userdata/privateKey")
    }
    source      = "./edge_env.sh"
    destination = "~/edge_env.sh"
  }
provisioner "file" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = file("./userdata/privateKey")
    }
    source      = "./userdata/privateKey"
    destination = "~/.ssh/bdsKey"
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "1m"
      host        = self.public_ip
      user        = "opc"
      private_key = file("./userdata/privateKey")
    }
    inline = [
      "chmod +x ~/bootstrap.sh",
      "sudo ~/bootstrap.sh",
    ]
  }
}