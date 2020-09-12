job "sockshop-catalogue" {
  datacenters = ["dc1"]

  group "catalogue" {
    network {
      mode = "bridge"

      port "http" {}
    }

    service {
      name = "sockshop-catalogue"
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-cataloguedb"
              local_bind_port  = 3306
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "catalogue" {
      driver = "docker"

      config {
        image   = "weaveworksdemos/catalogue:0.3.5"
        command = "/app"
        args = [
          "-port=${NOMAD_PORT_http}",
          "-DSN=catalogue_user:default_password@tcp(${NOMAD_UPSTREAM_ADDR_sockshop_cataloguedb})/socksdb"
        ]
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }
    }
  }

  group "cataloguedb" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-cataloguedb"
      port = "3306"

      connect {
        sidecar_service {}
      }
    }

    task "cataloguedb" {
      driver = "docker"

      config {
        image = "weaveworksdemos/catalogue-db:0.3.5"
      }

      env {
        MYSQL_DATABASE             = "socksdb"
        MYSQL_ROOT_PASSWORD        = ""
        MYSQL_ALLOW_EMPTY_PASSWORD = "true"
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
