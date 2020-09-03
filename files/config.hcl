log_level = "trace"
#plugin_dir = "/Users/laoqui/go/src/github.com/hashicorp/nomad-autoscaler-iss-demo/bin"
plugin_dir = "/Users/laoqui/go/src/github.com/hashicorp/nomad-aro-prototype/plugins/bin"

policy {
  dir = "/Users/laoqui/go/src/github.com/hashicorp/nomad-autoscaler/demo/vagrant/policies"
}

http {
  bind_port = 9999
}

apm "prometheus" {
  driver = "prometheus"

  config = {
    address = "http://localhost:9090"
  }
}

apm "aro-apm" {
  driver = "aro-apm"

  config = {
    prometheus    = "http://localhost:9090"
    window        = "5m"
    step          = "1s"
    preload_range = "12h"
  }
}

strategy "aro-strategy" {
  driver = "aro-strategy"

  config = {
    prometheus    = "http://localhost:9090"
    window        = "5m"
    step          = "1s"
    preload_range = "12h"
  }
}

target "nomad-job-metadata-target" {
  driver = "nomad-job-metadata-target"
}

#target "aws-asg" {
#  driver = "aws-asg"
#  config = {
#    aws_region = "us-east1"
#  }
#}

#strategy "pid" {
#  driver = "pid-strategy"
#}
