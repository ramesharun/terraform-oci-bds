resource "oci_functions_application" "bds-demo-app" {
  #Required
  compartment_id = local.compartment_ocid
  display_name   = "bds-demo-application"
  subnet_ids     = tolist([module.vcn.subnet_ids, ])

  #Optional
  // config = "${var.application_config}"
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_functions_function" "bds-demo-function" {
  #Required
  application_id = oci_functions_application.bds-demo-app.id
  display_name   = "bds-demo-function"
  image          = "iad.ocir.io/oraclebigdatadb/alexey/hello-java:0.0.3"
  memory_in_mbs  = "128"

  #Optional
  freeform_tags      = { "environment" = "bds-demo" }
  timeout_in_seconds = "60"
}

resource "oci_functions_invoke_function" "bds-demo-function-invoke" {
    depends_on = [oci_identity_policy.allow_bds_read_oci_resources]
  #Required
  function_id = oci_functions_function.bds-demo-function.id
}

resource "oci_apigateway_gateway" "bds-demo-gateway" {
  #Required
  compartment_id = local.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = module.vcn.subnet_ids

  #Optional
  display_name  = "bds-demo-api-gw"
  freeform_tags = { "environment" = "bds-demo" }
}


resource "oci_apigateway_deployment" "bds-demo-gw-deployment" {
    #Required
    compartment_id = local.compartment_ocid
    gateway_id = oci_apigateway_gateway.bds-demo-gateway.id
    path_prefix = "/v1"
    specification {
        routes {
            #Required
            backend {
                #Required
                type = "Oracle Function"
            }
            path = "/hello-tf"
            function_id = oci_functions_function.bds-demo-function.id
            methods = "GET"
        }
    }

    #Optional
    display_name = "bds-demo-deployment-tf"
    freeform_tags = { "environment" = "bds-demo" }
}