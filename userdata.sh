#!/bin/bash

# Atualizar e instalar pacotes necessários
sudo apt update && sudo apt upgrade -y

# Instalar o Nginx
sudo apt install nginx -y

# Iniciar o Nginx
sudo systemctl start nginx

# Configurar o git para fazer sparse-checkout
cd /tmp
git init
git remote add origin https://github.com/andrrade/Project1-CompassUOL-DevSecOps.git
git config core.sparseCheckout true

# Garantir que todo o conteúdo dentro de 'meu-site' (incluindo assets e styles) seja baixado
echo "meu-site/*" >> .git/info/sparse-checkout

# Baixar os arquivos da branch main do repositório
git pull origin main

# Mover os arquivos para o diretório /var/www/html/
sudo mv /tmp/meu-site/* /var/www/html/

# Configurar o Nginx para servir os arquivos
sudo nano /etc/nginx/sites-available/default <<EOF
server {
   listen 80;
   server_name localhost; # Nome do servidor (pode ser um domínio ou IP)

   root /var/www/html; # Caminho onde os arquivos do site estão armazenados
   index index.html;

   location / {
      try_files \$uri \$uri/ =404;
   }
}
EOF

# Reiniciar o Nginx para aplicar as configurações
sudo systemctl restart nginx

# Habilitar o Nginx para iniciar no boot
sudo systemctl enable nginx

# Configurar o Nginx para reiniciar automaticamente em caso de falhas
sudo nano /etc/systemd/system/multi-user.target.wants/nginx.service <<EOF
[Service]
Restart=always
RestartSec=30
EOF

# Atualizar o sistema de serviços
sudo systemctl daemon-reload

# Criar diretórios e arquivos de log
sudo mkdir -p /var/log/monitoramento
sudo touch /var/log/monitoramento/servico_online.log /var/log/monitoramento/servico_offline.log /var/log/monitoramento/geral.log

# Ajustar permissões para os logs
sudo chmod -R 755 /var/log/monitoramento
sudo chmod 666 /var/log/monitoramento/geral.log /var/log/monitoramento/servico_online.log /var/log/monitoramento/servico_offline.log

# Criar diretório para scripts de monitoramento
sudo mkdir -p /usr/local/bin/monitoramento/scripts

# Baixar o script de monitoramento
cd /tmp
curl -o /usr/local/bin/monitoramento/scripts/monitorar_site.sh https://raw.githubusercontent.com/andrrade/Project1-CompassUOL-DevSecOps/main/monitorar_site.sh

# Tornar o script executável
sudo chmod +x /usr/local/bin/monitoramento/scripts/monitorar_site.sh

# Instalar o cron
sudo apt install cron -y

# Habilitar o serviço cron para iniciar no boot
sudo systemctl enable cron

# Configurar o cron para executar o script a cada 1 minuto
echo "*/1 * * * * /usr/local/bin/monitoramento/scripts/monitorar_site.sh" | sudo crontab -

# Finalização
echo "Configuração completa. O servidor está pronto."
