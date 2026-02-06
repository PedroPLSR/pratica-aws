#!/bin/bash

echo "Iniciando deploy..."

# Terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Obter IP e atualizar inventory
PUBLIC_IP=$(terraform output -raw ip_publica)
cat > ansible/inventory.ini <<EOF
[webserver]
${PUBLIC_IP}

[webserver:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=../terraform-aws-key.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

# Aguardar SSH
echo "Aguardando SSH (60 segundos)..."
sleep 60

# Ansible
cd ansible
ansible-playbook -i inventory.ini playbooks/webserver.yml
cd ..

echo "Deploy concluído!"
terraform output url_publica
