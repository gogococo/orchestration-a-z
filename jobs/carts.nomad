job "sockshop-carts" {
  datacenters = ["dc1"]

  group "carts" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-carts"
      port = "80"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-cartsdb"
              local_bind_port  = 27017
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "carts" {
      driver = "docker"

      config {
        image = "weaveworksdemos/carts:0.4.8"
        args  = ["--db=localhost"]
      }

      env = {
        JAVA_OPTS = "-Xms64m -Xmx512m"
      }

      resources {
        cpu    = 100
        memory = 512
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }
    }
  }

  group "cartsdb" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-cartsdb"
      port = "27017"

      connect {
        sidecar_service {}
      }
    }

    task "cartsdb" {
      driver = "docker"

      config {
        image = "mongo:3.4"
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
