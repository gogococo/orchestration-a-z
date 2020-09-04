job "sockshop-frontend" {
  datacenters = ["dc1"]

  group "frontend" {
    network {
      mode = "bridge"

      port "http" {}
    }

    service {
      name = "sockshop-frontend"
      port = "http"

      check {
        name     = "frontend"
        type     = "http"
        port     = "http"
        path     = "/"
        interval = "5s"
        timeout  = "2s"
      }



      connect {
        sidecar_service {
          proxy {
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

    task "frontend" {
      driver = "docker"
      env {
        PORT = "${NOMAD_PORT_http}"
      }

      config {
        image = "weaveworksdemos/front-end:0.3.11"
        volumes = [
          "local/resolv.conf:/etc/resolv.conf"
        ]
        ports = ["http"]
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
        memory = 128
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }
    }
  }

  group "edgerouter" {
    network {
      mode = "bridge"

      port "http" {
        static = 80
        to     = 80
      }
    }

    service {
      name = "sockshop-edgerouter"
      port = "http"

      check {
        name     = "edgerouter"
        type     = "http"
        port     = "http"
        path     = "/ping"
        interval = "5s"
        timeout  = "2s"
      }

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-frontend"
              local_bind_port  = 8079
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "edgerouter" {
      driver = "docker"

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      config {
        image = "weaveworksdemos/edge-router:0.1.1"
        args = ["--ping"]        

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
        ports = ["http"]
      }

      template {
        data = <<EOF
logLevel = "INFO"

[web]
address = ":8080"

[entryPoints]
  [entryPoints.http]
    address = ":80"

[ping]
entryPoint = "http"

[file]
  [backends]
    [backends.backend1]
      [backends.backend1.loadbalancer]
        method = "wrr"
        sticky = true
      [backends.backend1.servers.server1]
        url = "http://{{ env "NOMAD_UPSTREAM_ADDR_sockshop_frontend" }}"

  [frontends]
    [frontends.frontend1]
      backend = "backend1"
      entrypoints = ["http"]
EOF

        destination = "local/traefik.toml"
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
}
