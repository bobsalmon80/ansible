
variable "proxmox_template_name" {
  type    = string
  default = "ubuntu-20.04"
}

variable "proxmox_vm_id" {
  type    = string
  default = "305"
}

variable "ubuntu_iso_file" {
  type    = string
  default = "ubuntu-20.04.2-live-server-amd64.iso"
}

locals {
  output_directory = "build/${legacy_isotime("2006-01-02-15-04-05")}"
}

source "proxmox-iso" "autogenerated_1" {
  cloud_init = true
  cloud_init_storage_pool = "local-lvm"
  boot_command = [
    "e<down><down><down><end><wait><bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/",
    "<f10>"
  ]
  boot = "c"
  boot_wait = "5s"
  cores = 2
  qemu_agent = true
  disks {
    disk_size         = "20G"
    format            = "raw"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    type              = "virtio"
  }
  http_directory   = "/home/smb/ansible/packer/http_root"
  http_bind_address = "192.168.101.3"
  http_port_min = 8802
  http_port_max = 8802
  iso_file         = "local:iso/ubuntu-22.04.2-live-server-amd64.iso"
  iso_storage_pool = "local"
  memory           = 2048
  network_adapters {
    bridge = "vmbr1"
    model = "virtio"
    mac_address = "00:00:00:00:00:01"
  }
  node            = "node5"
  password        = "1Qazxsw2"
  proxmox_url     = "https://192.168.101.2:8006/api2/json"
  scsi_controller = "virtio-scsi-pci"
  ssh_password    = "fDj80mDn12"
  ssh_timeout     = "45m"
  ssh_username    = "smb"
  ssh_host        = "192.168.101.70"
  template_name   = "${var.proxmox_template_name}"
  unmount_iso     = true
  username        = "root@pam"
  vm_id           = "${var.proxmox_vm_id}"
}

build {

    name = "ubuntu_server"
    sources = ["source.proxmox-iso.autogenerated_1"]
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]   
    }
}
