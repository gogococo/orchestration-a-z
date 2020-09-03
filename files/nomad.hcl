datacenter = "dc1"

data_dir = "/opt/nomad"

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true

  host_volume "grafana" {
    path = "/opt/nomad-volumes/grafana"
  }

  meta {
    "connect.log_level" = "debug"
  }

  network_interface = "enp0s3"
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}
