job "sockshop-shipping" {
  datacenters = ["dc1"]

  group "shipping" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-shipping"
      port = "80"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-rabbitmq"
              local_bind_port  = 5672
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "shipping" {
      driver = "docker"

      config {
        image = "weaveworksdemos/shipping:0.4.8"
        args  = ["--spring.rabbitmq.host=localhost"]
      }

      env = {
        JAVA_OPTS = "-Xms64m -Xmx128m"
      }

      resources {
        cpu    = 100
        memory = 256
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }
    }
  }

  group "queue-master" {
    network {
      mode = "bridge"
    }

    service {
      connect {
        sidecar_service {}
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "queue-master" {
      driver = "docker"

      config {
        image = "weaveworksdemos/queue-master:0.3.1"
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
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

  group "rabbitmq" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-rabbitmq"
      port = "5672"

      connect {
        sidecar_service {}
      }
    }

    task "rabbitmq" {
      driver = "docker"

      config {
        image = "rabbitmq:3.6.8"
      }

      resources {
        cpu    = 50
        memory = 128
      }
    }
  }
}
