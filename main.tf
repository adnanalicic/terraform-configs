locals {
  nodes = {
    "node-01" = {
      name      = "node-01"
    },
    "node-02" = {
      name      = "node-02"
    }
  }
}

terraform {
  required_providers {
    virtualbox = {
      source = "shekeriev/virtualbox"
      version = "0.0.4"
    }
  }
}

provider "virtualbox" {
  # Configuration options

}

resource "virtualbox_vm" "node" {
  for_each = local.nodes
  
  
  name      = each.value.name
  image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  cpus      = 2
  memory    = "512 mib"
  user_data = file("/home/aalicic/working_directory/terraform/user_data.txt")

  network_adapter {
    type           = "bridged"
    host_interface = "wlp0s20f3"
  }

    # Use the remote-exec provisioner to upload the custom sshd_config file
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sudo systemctl restart sshd"
    ]

    connection {
      type        = "ssh"
      host        = each.value.network_adapter[0].ipv4_address
      user        = "vagrant"
      private_key = file("/home/aalicic/working_directory/terraform/vagrantprivatekey")
    }
  }

}

#output "IPAddr" {
#  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
#}