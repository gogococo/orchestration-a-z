job "sockshop-payment" {
  datacenters = ["dc1"]

  group "payment" {
    network {
      mode = "bridge"

      port "http" {}
    }

    service {
      name = "sockshop-payment"
      port = "http"

      connect {
        sidecar_service {}
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "payment" {
      driver = "docker"

      config {
        image   = "weaveworksdemos/payment:0.4.3"
        command = "/app"
        args    = ["-port=${NOMAD_PORT_http}"]
        ports   = ["http"]
      }

      resources {
        cpu    = 100
        memory = 16
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }
    }
  }
}
