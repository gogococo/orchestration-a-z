job "sockshop-loadtest" {
  datacenters = ["dc1"]
  type        = "batch"

  parameterized {
    payload       = "optional"
    meta_optional = ["delay", "clients", "requests"]
  }

  group "load" {
    network {
      mode = "bridge"
    }

    task "coredns" {
      lifecycle {
        sidecar = true
        hook    = "prestart"
      }

      template {
        destination = "local/Corefile"
        data        = <<EOF
consul {
    forward . {{ range service "consul" }}{{ .Address }}:8600 {{ end }}
    log
}

. {
    forward . /etc/resolv.conf
    log
}
EOF
      }

      driver = "docker"
      config {
        image = "coredns/coredns:1.7.0"
        args  = ["-conf", "/local/Corefile"]
      }
    }

    task "gen" {
      template {
        destination = "secrets/env.txt"
        env         = true
        data        = <<EOF
DELAY={{ or (env "NOMAD_META_delay") "1" }}
CLIENTS={{ or (env "NOMAD_META_clients") "2" }}
REQUESTS={{ or (env "NOMAD_META_requests") "100" }}
EOF
      }

      template {
        destination = "local/resolv.conf"
        data        = <<EOF
search node.consul
nameserver 127.0.0.1
EOF
      }

      driver = "docker"
      config {
        image = "weaveworksdemos/load-test:0.1.1"
        args = [
          "-d", "${DELAY}",
          "-h", "sockshop-edgerouter.service.consul",
          "-c", "${CLIENTS}",
          "-r", "${REQUESTS}"
        ]
        volumes = [
          "local/resolv.conf:/etc/resolv.conf"
        ]
      }
    }
  }
}
