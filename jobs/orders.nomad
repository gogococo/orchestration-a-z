job "sockshop-orders" {
  datacenters = ["dc1"]

  group "orders" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-orders"
      port = "8080"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-ordersdb"
              local_bind_port  = 27017
            }

            upstreams {
              destination_name = "sockshop-proxy"
              local_bind_port  = 80
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "orders" {
      driver = "docker"

      config {
        image = "weaveworksdemos/orders:0.4.7"

        entrypoint = []
        command    = "/usr/local/bin/java.sh"
        args = [
          "-jar",
          "./app.jar",
          "--db=localhost",
          "--port=8080"
        ]

        volumes = [
          "local/resolv.conf:/etc/resolv.conf"
        ]
      }

      env = {
        JAVA_OPTS = "-Xms64m -Xmx512m"
      }

      template {
        data = <<EOH
{{- range service "sockshop-dns" -}}
nameserver {{ .Address }}
{{ end -}}
nameserver 8.8.8.8
EOH

        destination = "local/resolv.conf"
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

  group "ordersdb" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-ordersdb"
      port = "27017"

      connect {
        sidecar_service {}
      }
    }

    task "ordersdb" {
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
