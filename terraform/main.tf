terraform {
  required_version = ">= 0.13.0"
  backend "http" {
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">=2.7.4"
    }
  }
}

provider "proxmox" {
  ## TODO - FIX URL
  pm_api_url      = "https://10.101.21.41:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_parallel     = 1
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

variable "branch" {
  type        = string
  description = "Git branch, which is also used as subdomain name."
}

variable "subnet" {
  type        = string
  description = "Subnet for the branch in format 192.168.1.0/24"
}

variable "subnet_list" {
  type        = string
  description = "List of all subnets and branches in JSON format"
}

locals {
  cidr_suffix = element(split("/", var.subnet), 1)
  domain      = "${var.branch}.magevent.net"
}

resource "local_file" "inventory" {
  filename = "./hosts.ini"
  content  = <<-EOF
    [dhcp]
    ${module.dhcp.hostname} ansible_host=${module.dhcp.ip_address}

    [dns]
    ${module.dns[0].hostname} ansible_host=${module.dns[0].ip_address}
    ${module.dns[1].hostname} ansible_host=${module.dns[1].ip_address}

    [ntp]
    ${module.ntp[0].hostname} ansible_host=${module.ntp[0].ip_address}
    ${module.ntp[1].hostname} ansible_host=${module.ntp[1].ip_address}

    [tftp]
    ${module.tftp.hostname} ansible_host=${module.tftp.ip_address}

    [cups]
    ${module.cups.hostname} ansible_host=${module.cups.ip_address}

    [rsyslog]
    ${module.rsyslog.hostname} ansible_host=${module.rsyslog.ip_address}

    [smtp]
    ${module.smtp.hostname} ansible_host=${module.smtp.ip_address}

    [laptops]
    ${module.laptops.hostname} ansible_host=${module.laptops.ip_address}
    EOF
}
