# Simple local orchestration: bring up Vagrant VM and then run Ansible playbook
terraform {
  required_providers { }
}

variable "project_root" {
  description = "Relative path to repo root from this terraform directory"
  default     = ".."
}

resource "null_resource" "vagrant_and_ansible" {
  provisioner "local-exec" {
    command = "cd ${var.project_root} && vagrant up"
  }

  provisioner "local-exec" {
    # Run ansible-playbook from repo root; using your inventory file if inventory.yml exists
    command = "cd ${var.project_root} && ansible-playbook -i inventory.yml playbook.yml --tags=deploy"
  }
}
