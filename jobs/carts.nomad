job "sockshop-carts" {
  datacenters = ["dc1"]

  group "carts" {
    network {
      mode = "bridge"

      port "http" {}
    }

    service {
      name = "sockshop-carts"
      port = "http"

      check {
        name     = "carts"
        type     = "http"
        port     = "http"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
      }

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

        entrypoint = [
          "java",
          "-Djava.security.egd=file:/dev/urandom",
          "-jar",
          "./app.jar"
        ]

        args = [
          "--db=localhost",
          "--port=${NOMAD_PORT_http}"
        ]

        ports = ["http"]
      }

      env = {
        JAVA_OPTS = "-Xms64m -Xmx512m"
      }

      resources {
        cpu    = 100
        memory = 1024
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
