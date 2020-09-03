job "sockshop-payment" {
  datacenters = ["dc1"]

  group "payment" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-payment"
      port = "80"

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
        image = "weaveworksdemos/payment:0.4.3"
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
