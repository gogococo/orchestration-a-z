job "sockshop-user" {
  datacenters = ["dc1"]

  group "user" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-user"
      port = "80"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-userdb"
              local_bind_port  = 27017
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "user" {
      driver = "docker"

      config {
        image = "weaveworksdemos/user:0.4.7"
      }

      env {
        MONGO_HOST = "localhost"
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

  group "userdb" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-userdb"
      port = "27017"

      connect {
        sidecar_service {}
      }
    }

    task "userdb" {
      driver = "docker"

      config {
        image = "weaveworksdemos/user-db:0.4.7"
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
