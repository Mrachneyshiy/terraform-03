# Домашнее задание к занятию "Управляющие конструкции в коде Terraform"

## Задача 1
Приложите скриншот входящих правил "Группы безопасности" в ЛК Yandex Cloud  или скриншот отказа в предоставлении доступа к preview версии.

## Ответ:

![](pic/1.png) 

## Задача 2
1. Создайте файл count-vm.tf. Опишите в нем создание двух **одинаковых** ВМ  web-1 и web-2(не web-0 и web-1!), с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в 1-м задании группу безопасности.
2. Создайте файл for_each-vm.tf. Опишите в нем создание 2 ВМ с именами "main" и "replica" **разных** по cpu/ram/disk , используя мета-аргумент **for_each loop**. Используйте для обеих ВМ одну, общую переменную типа list(object({ vm_name=string, cpu=number, ram=number, disk=number  })). При желании внесите в переменную все возможные параметры.
3. ВМ из пункта 2.2 должны создаваться после создания ВМ из пункта 2.1.
4. Используйте функцию file в local переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ №2.
5. Инициализируйте проект, выполните код.


## Ответ:
<details>
<summary>count-vm.tf</summary>

``` sh
resource "yandex_compute_instance" "backend" {
  count       = 2
  name        = "web-${count.index + 1}"
  platform_id = "standard-v1"
  resources {
    cores         = var.vm_base.cores
    memory        = var.vm_base.memory
    core_fraction = var.vm_base.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  metadata = local.ssh_keys_and_serial_port

}
``` 
</details>

<details>
<summary>for_each-vm.tf</summary>

``` sh
rresource "yandex_compute_instance" "frontend" {

  for_each = local.virtual_machines

  name        = each.value.vm_name
  platform_id = "standard-v1"
  resources {
    cores         = each.value.vm_cpu
    memory        = each.value.vm_ram
    core_fraction = each.value.vm_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.vm_disk_size
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  metadata = local.ssh_keys_and_serial_port

  depends_on = [
    yandex_compute_instance.backend
  ]

}
``` 
</details>

<details>
<summary>locals.tf</summary>

``` sh
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
``` 
</details>

![](pic/2.png) 

## Задача 3

1. Создайте 3 одинаковых виртуальных диска, размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
2. Создайте в том же файле одну ВМ c именем "storage" . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.

## Ответ:
![](pic/3.png) 
------
![](pic/4.png) 

## Задача 4
1. В файле ansible.tf создайте inventory-файл для ansible.
Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/demonstration2).
Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2.(т.е. 5 ВМ)
2. Инвентарь должен содержать 3 группы [webservers], [databases], [storage] и быть динамическим, т.е. обработать как группу из 2-х ВМ так и 999 ВМ.
4. Выполните код. Приложите скриншот получившегося файла. 

## Ответ:
![](pic/5.png) 
------
![](pic/6.png) 