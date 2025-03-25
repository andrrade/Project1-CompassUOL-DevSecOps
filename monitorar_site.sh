#!/usr/bin/env bash

# Defina as variáveis de configuração
BOT_TOKEN="" # PREENCHA AQUI O TOKEN GERADO PELO BOT
CHAT_ID="" # PREENCHA SEU CHAT_ID
LOGS="/var/log/monitoramento/geral.log"
LOG_ONLINE="/var/log/monitoramento/servico_online.log"
LOG_OFFLINE="/var/log/monitoramento/servico_offline.log"

# Defina as variáveis de cor
COR_OK="\033[32m"
COR_ALERTA="\033[31m"
COR_INFO="\033[34m"
COR_RESET="\033[0m"

# Função para verificar se o token e chat_id estão preenchidos corretamente
verificar_configuracao() {
   if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ] || [ "$BOT_TOKEN" == "PREENCHA AQUI O TOKEN GERADO PELO BOT" ] || [ "$CHAT_ID" == "PREENCHA SEU CHAT_ID" ]; then
      echo -e "${COR_ALERTA}⛔ Erro: BOT_TOKEN ou CHAT_ID não estão preenchidos corretamente.${COR_RESET}"
      exit 1
   fi
}

# Função para enviar alerta para o Telegram
enviar_alerta() {
   local MENSAGEM="$1"
   echo -e "${COR_INFO}🔔 Enviando alerta para o Telegram...${COR_RESET}"
   curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d "chat_id=$CHAT_ID" \
      -d "text=$MENSAGEM" > /dev/null 2>&1
}

# Função para verificar o status do site
verificar_status_site() {
   STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
   TIME_VIRGINIA=$(date "+%d-%m-%Y %H:%M:%S")  # Hora em Virginia
   TIME_BRASIL=$(TZ="America/Sao_Paulo" date "+%d-%m-%Y %H:%M:%S")  # Hora no Brasil
   
   case $STATUS in
      200)
            SITE_STATUS="✅ O site está ONLINE!"
            # Registro no log de online com cor
            echo -e "${COR_OK}$TIME_VIRGINIA (Virginia) | $TIME_BRASIL (Brasil) - $SITE_STATUS${COR_RESET}" >> "$LOG_ONLINE"
            # Registro no log geral com cor
            echo -e "${COR_OK}$TIME_VIRGINIA (Virginia) | $TIME_BRASIL (Brasil) - $SITE_STATUS${COR_RESET}" >> "$LOGS"
            ;;
      *)
            SITE_STATUS="⛔ O serviço está OFFLINE! Status: $STATUS"
            # Registro no log de offline com cor
            echo -e "${COR_ALERTA}$TIME_VIRGINIA (Virginia) | $TIME_BRASIL (Brasil) - $SITE_STATUS${COR_RESET}" >> "$LOG_OFFLINE"
            # Registro no log geral com cor
            echo -e "${COR_ALERTA}$TIME_VIRGINIA (Virginia) | $TIME_BRASIL (Brasil) - $SITE_STATUS${COR_RESET}" >> "$LOGS"
            ;;
   esac
}

# Função para verificar as portas
verificar_portas() {
   # Verifica a porta 80 (HTTP)
   if nc -zv 127.0.0.1 80 &> /dev/null; then
      PORTA_80="✅ Porta 80 (HTTP) está FUNCIONANDO"
   else
      PORTA_80="⛔ Porta 80 (HTTP) está INDISPONÍVEL"
   fi

   # Verifica a porta 443 (HTTPS)
   if nc -zv 127.0.0.1 443 &> /dev/null; then
      PORTA_443="✅ Porta 443 (HTTPS) está FUNCIONANDO"
   else
      PORTA_443="⛔ Porta 443 (HTTPS) está INDISPONÍVEL"
   fi
}

# Função para reiniciar o Nginx
reiniciar_nginx() {
   if ! sudo systemctl is-active --quiet nginx; then
      NGINX_STATUS="⛔ Nginx está INATIVO ou com problema!"
      
      # Tenta reiniciar o Nginx
      echo -e "${COR_INFO}🔄 Tentando reiniciar o Nginx...${COR_RESET}"
      if sudo systemctl restart nginx > /dev/null 2>&1; then
            NGINX_REINICIADO="✅ Nginx foi REINICIADO com SUCESSO!"
            verificar_portas  # Verifica as portas novamente após reiniciar
            verificar_status_site  # Verifica o status do site novamente após reiniciar
      else
            NGINX_REINICIADO="⛔ Não foi possível reiniciar o Nginx!"
      fi
   else
      NGINX_STATUS="✅ Nginx está ATIVO e funcionando!"
      NGINX_REINICIADO="😁 Não foi necessário reiniciar o Nginx."
   fi
}

# Função para verificar o status do Nginx
verificar_status_nginx() {
   NGINX_STATUS=""

   reiniciar_nginx
}

# Função para criar pastas e arquivos faltantes
criar_pastas_arquivos() {
   for log_file in "$LOGS" "$LOG_ONLINE" "$LOG_OFFLINE"; do
      if [ ! -e "$log_file" ]; then
            dir_name=$(dirname "$log_file")
            if [ ! -d "$dir_name" ]; then
               mkdir -p "$dir_name"  # Cria o diretório
            fi
            touch "$log_file"      # Cria o arquivo
      fi
   done
}

# Função para exibir saída no terminal de forma organizada
exibir_saida_terminal() {
   echo -e "${COR_INFO}🕒 Data e Hora (Virginia): $TIME_VIRGINIA | Data e Hora (Brasil): $TIME_BRASIL${COR_RESET}"

   echo -e "${COR_INFO}\n⚙️ Status das Portas:${COR_RESET}"
   echo -e "$PORTA_80"
   echo -e "$PORTA_443"

   echo -e "${COR_INFO}\n🔧 Status do Nginx:${COR_RESET}"
   echo -e "$NGINX_STATUS"

   echo -e "${COR_INFO}\n🔄 Reinício do Nginx:${COR_RESET}"
   echo -e "$NGINX_REINICIADO"

   echo -e "${COR_INFO}\n🌐 Status do Site:${COR_RESET}"
   echo -e "$SITE_STATUS"

   echo -e "${COR_INFO}\n📂 Logs:${COR_RESET}"
   echo -e "- Geral: $LOGS"
   echo -e "- Online: $LOG_ONLINE"
   echo -e "- Offline: $LOG_OFFLINE"

   echo -e "${COR_INFO}🎉 Script executado com SUCESSO! Veja os logs para mais detalhes.${COR_RESET}"
}

# Função para iniciar o processo completo
executar_script() {
   verificar_configuracao
   criar_pastas_arquivos
   verificar_status_site
   verificar_portas
   verificar_status_nginx
}

# Chama a função principal para executar o script
executar_script

# Criando o texto consolidado para enviar ao Telegram sem cores
MENSAGEM="
🕒 Hora (Virginia): $TIME_VIRGINIA
🕒 Hora (Brasil): $TIME_BRASIL

⚙️ Status das Portas:
$PORTA_80
$PORTA_443

🔧 Status do Nginx:
$NGINX_STATUS

🔄 Reinício do Nginx:
$NGINX_REINICIADO

🌐 Status do Site:
$SITE_STATUS

📂 Logs:
- Geral: $LOGS
- Online: $LOG_ONLINE
- Offline: $LOG_OFFLINE

🎉 Script executado com SUCESSO!
"

# Enviar a mensagem consolidada para o Telegram
enviar_alerta "$MENSAGEM"

# Exibe as informações no terminal
exibir_saida_terminal
