<div align="center">
  <h1>
    <img src="./assets/Shuckle.svg" width="40" height="40" alt="Shuckle" style="vertical-align: middle;">
    Shuckle Firewall
  </h1>
  <p>Firewall Automatizado com IPTables para Linux</p>
  
  <p>
    <img src="https://img.shields.io/badge/Shell_Script-100%25-brightgreen" alt="Shell">
    <img src="https://img.shields.io/badge/Security-FF6B6B" alt="Security">
    <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
  </p>
</div>

## Visão Geral

O Shuckle Firewall é uma solução robusta para proteção de servidores Linux, oferecendo:

- Configuração automatizada de firewall via iptables
- Controle granular de tráfego de rede
- Proteção contra acessos não autorizados
- Fácil personalização via variáveis de ambiente

## Funcionalidades Principais

**Proteção Essencial**  
- Bloqueio de portas potencialmente perigosas  
- Permissão apenas para serviços essenciais (SSH, HTTP, HTTPS)  
- Proteção contra ataques de força bruta  

**Configuração Flexível**  
- Variáveis de ambiente para personalização fácil  
- Suporte a IPs confiáveis (whitelist)  
- Opção de logging para tentativas bloqueadas  

**Gerenciamento Simplificado**  
- Salva automaticamente as regras configuradas  
- Restauração fácil das configurações  
- Visualização clara do status atual  

## Pré-requisitos

- Linux com iptables instalado
- Bash 4.0+
- Permissões de root/sudo

## Instalação Rápida

1. Clone o repositório:

```bash
git clone https://github.com/GirardiMatheus/shuckle.git && cd shuckle
```

2. Configure o ambiente:

```bash
cp .env.example .env
# Edite as variáveis conforme necessário
nano .env
```

3. Torne o script executável:

```bash
chmod +x firewall.sh
```

## Como Usar

**Ativar firewall:**

```bash
Ativar firewall:
```

**Desativar firewall (modo permissivo):**

```bash
sudo ./firewall.sh stop
```

**Salvar regras manualmente:**

```bash
sudo ./firewall.sh save
```

**Ver status atual:**

```bash
sudo ./firewall.sh status
```

**Modo debug:**

```bash
DEBUG=true sudo -E ./firewall.sh start
```

## Estrutura do Projeto

```bash
shuckle/
├── firewall.sh             # Script principal
├── .env.example         # Template de configuração
├── assets/
│   └── Shuckle.svg     # Ícone do projeto
└── README.md       # Esta documentação
```

## Melhores Práticas

1. Configuração básica recomendada:

```bash
# No arquivo .env
ALLOWED_PORTS="22 80 443"                   # Portas essenciais
BLOCKED_PORTS="21 23 137-139 445"     # Portas comuns de ataques
LOG_DROPPED="yes"                                   # Habilitar logs
```

2. Agendamento para salvar regras periodicamente:

```bash
# Adicione ao crontab
0 * * * * /caminho/para/shuckle-firewall/firewall.sh save
```

3. Restaurar regras na inicialização:

```bash
# Adicione ao /etc/rc.local (antes do exit 0)
/path/to/firewall.sh restore
```

## Contribuição

1. Fork o projeto
2. Crie sua branch (git checkout -b feature/nova-funcionalidade)
3. Commit suas mudanças (git commit -am 'Add nova funcionalidade')
4. Push para a branch (git push origin feature/nova-funcionalidade)
5. Abra um Pull Request