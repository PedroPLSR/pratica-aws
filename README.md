# Prática AWS

Projeto de infraestrutura AWS usando Terraform e Ansible.

## Estrutura do Projeto

- **Terraform**: Provisionamento de infraestrutura na AWS
- **Ansible**: Configuração e gerenciamento de servidores

## Pré-requisitos

- Terraform
- Ansible
- AWS CLI configurado
- Credenciais AWS

## Como usar

1. Execute o script de deploy:
```bash
./deploy.sh
```

## Estrutura de Pastas

```
├── main.tf              # Configuração principal do Terraform
├── deploy.sh            # Script de deployment
└── ansible/
    ├── ansible.cfg      # Configuração do Ansible
    ├── inventory.ini    # Inventário de hosts
    ├── playbooks/       # Playbooks Ansible
    └── templates/       # Templates Jinja2
```
