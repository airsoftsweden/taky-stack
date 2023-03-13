# taky-stack

terraform\secrets.tfvars
```
ssh_key            = "c:\\PATH\\TO\\.ssh\\id_rsa"
ssh_fingerprint    = "SSH Fingerprint from Digital Ocean"

namecheap_username = "NameCheap Username"
namecheap_api_user = "NameCheap API User"
namecheap_api_key  = "NameCheap API Token"
do_token           = "DigitalOcean API Token"

servers            = ["ServerNames"]
cert_pass          = "atakatak"
```

Then `cd` into terraform, run `terraform init` and `terraform apply --var-file="secrets.tfvars"`

Once running and terraform is finished, ssh to server and run `cd /opt/ansible && ansible-playbook -i ansible_hosts certs.yml` to generate Certs for connection

Or run `cd /opt/ansible && ansible-playbook -i ansible_hosts taky-services.yml` to start the side services for taky (RTSP server etc.)