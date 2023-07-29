locals {
  virtual_machines = {
    "vm1" = { vm_name = "main", vm_cpu = 2, vm_ram = 1, vm_disk_size = 10, vm_core_fraction = 5 },
    "vm2" = { vm_name = "replica", vm_cpu = 2, vm_ram = 1, vm_disk_size = 15, vm_core_fraction = 20 }
  }

  ssh_keys_and_serial_port = {
    ssh-keys           = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}