datacenter       = "dc1"
advertise_addr   = "10.0.2.15"
client_addr      = "0.0.0.0"
data_dir         = "/opt/consul"
server           = true
bootstrap_expect = 1
ui               = true

telemetry {
  prometheus_retention_time = "30s"
}

ports {
  grpc = 8502
}

connect {
  enabled = true
}
