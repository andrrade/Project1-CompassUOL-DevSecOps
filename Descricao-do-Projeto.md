Turma de PB FEV 2025 | Programa de Bolsas DevSecOps

Atividade de Linux

Etapa 1: Configuração do Ambiente
- Criar uma VPC com 2 sub-redes públicas e 2 privadas.
- Criar uma instância EC2 na AWS, com Sistema Operacional Ubuntu ou Amazon 
Linux 2023, na VPC criada e na sub-rede pública;

Etapa 2: Configuração do Servidor Web
- Subir um servidor Nginx na EC2;
- Criar uma página simples em html que será exibida dentro do servidor Nginx.

Etapa 3: Script de Monitoramento + Webhook
- Criar um script que verifique a cada 1 minutos se o site está disponível, ou seja se 
ele está rodando normalmente, caso a aplicação não esteja funcionando, o script 
deve envio uma notificação via algum desses canais, Discord, Telegram ou Slack, 
informando da indisponibilidade do serviço.
- O script deve armazenar os logs da sua execução em um local no servidor, por 
exemplo: /var/log/meu_script.log

Etapa 4: Testes e Documentação
- Testar a implementação.
- Fazer a documentação explicando o processo de instalação do Linux no Github.
* Cuidado com dados que podem comprometer a segurança.
Desafios Bônus:
- A configuração da EC2 com o Nginx, página html e scripts de monitoramento são 
injetados automaticamente via User Data, para inicializarem junto com a máquina.
- Criar um arquivo Cloudformation que inicialize todo o ambiente