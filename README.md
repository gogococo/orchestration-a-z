# In This Demo

We set up the infrastructure on GCP, using [Terraform Nomad Google](https://github.com/picatz/terraform-google-nomad)
This demo will be using an updated version of the [Sock Shop demo](https://microservices-demo.github.io/)
for Nomad.

## Running the demo - Infra
Following the README from [Terraform Nomad Google](https://github.com/picatz/terraform-google-nomad)

### Getting Started
Create a Terraform main.tf based on the example file

### Bootstrapping ACLs  

nomad acl bootstrap \
-ca-cert=nomad-ca.pem \
-client-cert=nomad-cli-cert.pem \
-client-key=nomad-cli-key.pem

export NOMAD_TOKEN="${token}"

consul acl bootstrap \
-ca-cert=consul_ca_cert.pem \
-client-cert=consul-cli-cert.pem \
-client-key=consul-cli-key.pem

export CONSUL_TOKEN="${token}"

### Use ssh-mtls-terminating-proxy to access the UIs
* Note that we modified files from [Terraform Nomad Google](https://github.com/picatz/terraform-google-nomad)
* Modified files only are included in /infra for visibility on the changes we made
go run command

go run ssh-mtls-terminating-proxy.go \
-server-ip="${server-ip}" \
-bastion-ip="${bastion-ip}" \
-bastion-ssh-file="bastion-ssh.pem" \
-ca-file="nomad-ca.pem" \
-cert-file="nomad-cli-cert.pem" \
-key-file="nomad-cli-key.pem" \
-consul-ca-file="consul_ca_cert.pem" \
-consul-cert-file="consul-cli-cert.pem" \
-consul-key-file="consul-cli-key.pem"

## Running the demo - SockShop
