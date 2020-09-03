# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # Expose ports to the host.
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "0.0.0.0"    # Nomad
  config.vm.network "forwarded_port", guest: 4646, host: 4646, host_ip: "0.0.0.0"    # Nomad
  config.vm.network "forwarded_port", guest: 8500, host: 8500, host_ip: "0.0.0.0"    # Consul UI
  config.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "0.0.0.0"    # Prometheus
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "0.0.0.0"    # Grafana

  # Share current directory with jobs and configuration files with the VM.
  config.vm.synced_folder "./", "/home/vagrant/sockshop"

  # VM configuration.
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"
    vb.cpus = 4
  end

  # Provision demo dependencies.
  #   - Downloads and install Nomad, Consul and Docker
  # Only runs when the VM is created.
  config.vm.provision "deps", type: "shell", inline: <<-SHELL

    mkdir /tmp/downloads

    # Install dependencies.
    apt-get update
    apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      jq \
      make \
      software-properties-common \
      zip

    nomad_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r '.current_version')
    consul_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r '.current_version')

    # Download and install Docker.
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    apt-get update
    apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io
    docker run hello-world
    usermod -aG docker vagrant

    # Download and install Nomad and Consul.
    pushd /tmp/downloads
    curl --silent --show-error --remote-name-all \
      https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip \
      https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
    unzip nomad_${nomad_version}_linux_amd64.zip
    unzip consul_${consul_version}_linux_amd64.zip
    mkdir -p /opt/hashicorp/bin
    mv nomad consul /opt/hashicorp/bin
    chmod +x /opt/hashicorp/bin/{nomad,consul}
    ln -s /opt/hashicorp/bin/{nomad,consul} /usr/local/bin
    popd

    # Install CNI plugins for Consul Connect
    curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz
    sudo mkdir -p /opt/cni/bin
    sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

    rm -fr /tmp/downloads
  SHELL

  # Setup demo dependencies.
  #   - Create daemons for Nomad and Consul
  # Runs everytime the VM starts.
  config.vm.provision "app:setup", type: "shell", run: "always", inline: <<-SHELL
    # create paths for Nomad host volumes
    mkdir -p /opt/nomad-volumes
    pushd /opt/nomad-volumes
    mkdir -p grafana
    chown 472:472 grafana
    popd

    # configure Nomad and Consul daemons
    pushd /home/vagrant/sockshop/files
    for t in consul nomad; do
      cp ${t}.service /etc/systemd/system/
      mkdir -p /etc/${t}.d
      cp ${t}.hcl /etc/${t}.d/
      systemctl enable $t
      systemctl start $t
    done
    popd
  SHELL

end
