data "vsphere_datacenter" "dc" {
  name = "qacavern"
}

data "vsphere_datastore" "datastore" {
  name          = "vmstore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "LinRP"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "terraform-test-p"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "centos7"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test-nico"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder            = "dev_zone"

  num_cpus = 2
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = "pvscsi"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "e1000"
  }

  disk {
    label            = "disk0"
    size             = 40
    eagerly_scrub    = true
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "terraform-test"
        domain    = "runvmc.local"
      }
      network_interface {}
    }
  }
}
