job "sockshop-infra" {
  datacenters = ["dc1"]

  group "proxy" {
    network {
      mode = "bridge"
    }

    service {
      name = "sockshop-proxy"
      port = "80"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "sockshop-carts"
              local_bind_port  = 8080
            }

            upstreams {
              destination_name = "sockshop-catalogue"
              local_bind_port  = 8081
            }

            upstreams {
              destination_name = "sockshop-orders"
              local_bind_port  = 8082
            }

            upstreams {
              destination_name = "sockshop-payment"
              local_bind_port  = 8083
            }

            upstreams {
              destination_name = "sockshop-shipping"
              local_bind_port  = 8084
            }

            upstreams {
              destination_name = "sockshop-user"
              local_bind_port  = 8085
            }
          }
        }
      }
    }

    ephemeral_disk {
      size = 100
    }

    task "proxy" {
      driver = "docker"

      config {
        image = "traefik:v2.2"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "local/traefik.d/:/etc/traefik.d",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
  [entryPoints.http]
    address = ":80"

[providers.file]
  directory = "/etc/traefik.d/"

[accessLog]
  filePath = "/dev/stderr"

[log]
  level = "INFO"
EOF

        destination = "local/traefik.toml"
      }

      template {
        data = <<EOF
{{- scratch.Set "services" ("carts,catalogue,orders,payment,shipping,user" | split ",") -}}
[http]
  [http.routers]
{{- range $i, $s := scratch.Get "services" }}
    [http.routers.{{ $s }}]
      entryPoints = ["http"]
      service = "{{ $s }}"
      rule = "Host(`{{ $s }}`)"
{{- end }}
  [http.services]
{{- range $i, $s := scratch.Get "services" }}
    [http.services.{{ $s }}.loadBalancer]
      [[http.services.{{ $s }}.loadBalancer.servers]]
        url = "http://{{ env ("NOMAD_UPSTREAM_ADDR_sockshop_%s" | replaceAll "%s" $s) }}"
{{- end }}
EOF

        destination = "local/traefik.d/routes.toml"
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

  group "dns" {
    ephemeral_disk {
      size = 100
    }

    task "dns" {
      driver = "docker"

      config {
        image = "andyshinn/dnsmasq:2.78"

        port_map {
          dns = 53
        }

        volumes = [
          "local/dnsmasq.conf:/etc/dnsmasq.conf",
          "local/dnsmasq.hosts:/etc/dnsmasq.hosts",
        ]
      }

      service {
        name         = "sockshop-dns"
        address_mode = "host"
        port         = "dns"
      }

      template {
        data = <<EOF
no-dhcp-interface=
server=8.8.8.8
user=root
log-facility=/dev/stderr

no-hosts
addn-hosts=/etc/dnsmasq.hosts
EOF

        destination = "local/dnsmasq.conf"
      }

      template {
        data = <<EOF
{{- scratch.Set "services" ("carts,catalogue,orders,payment,shipping,user" | split ",") -}}
{{- range $i, $s := scratch.Get "services" }}
127.0.0.1 {{ $s }}
{{- end }}
EOF

        destination = "local/dnsmasq.hosts"
      }

      resources {
        cpu    = 100
        memory = 128

        network {
          port "dns" {
            static = 53
          }
        }
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }
    }
  }
}
