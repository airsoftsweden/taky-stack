resource "digitalocean_droplet" "atak-docker-do" {
  count = length(var.servers)
  image = "ubuntu-20-04-x64"
  name = "taky-docker-do-${var.servers[count.index]}"
  region = "ams3"
  size = "s-1vcpu-1gb"
  ssh_keys = [ var.ssh_fingerprint ]
  
  connection {
    host  = self.ipv4_address
    user  = "root"
    type = "ssh"
    private_key = file(var.ssh_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-add-repository -y ppa:ansible/ansible",
      "apt update",
      "apt install -y git",
      "apt install -y ansible"
    ]
  }

  provisioner "file" {
    source = "../ansible"
    destination = "/opt/ansible"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root",
      "echo 'export TAKY_SERVER=${var.servers[count.index]}' >> .bash_profile",
      "echo 'export IP=${var.servers[count.index]}.airsoftsweden.com' >> .bash_profile",
      "echo 'export ID=ATAK-${var.servers[count.index]}' >> .bash_profile",
      "echo 'export KEY_PW=${var.cert_pass}' >> .bash_profile",
      "echo 'export SERVER_P12_PW=${var.cert_pass}' >> .bash_profile"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "export TAKY_SERVER=${var.servers[count.index]}",
      "export IP=${var.servers[count.index]}.airsoftsweden.com",
      "export ID=ATAK-${var.servers[count.index]}",
      "export KEY_PW=${var.cert_pass}",
      "export SERVER_P12_PW=${var.cert_pass}",
      "cd /opt/ansible",
      "ansible-galaxy collection install -r requirements.yml",
      "ansible-playbook -i ansible_hosts taky.yml"
    ]
  }
}

resource "namecheap_domain_records" "milsim-airsoftsweden" {
  domain = "airsoftsweden.com"
  mode = "MERGE"
  count = length(var.servers)

  record {
    hostname = "${var.servers[count.index]}"
    type = "A"
    address = digitalocean_droplet.atak-docker-do[count.index].ipv4_address
  }
}
