<p align="center">
  <img src="assets/projeto-logo.png" alt="Projeto Logo" width="600">
</p>
<br>

# Documentação do 1º Projeto - DevSecOps ♾️

## 🔧 Ferramentas Úteis  

### ZoomIt da Microsoft para Prints de Tela com Setas
Para capturar telas com anotações, utilizei o ZoomIt da Microsoft.

- Documentação e instalação do ZoomIt: [ZoomIt - Sysinternals | Microsoft Learn](https://learn.microsoft.com/pt-br/sysinternals/downloads/zoomit)

## 📌 Pré-Requisitos 
Antes de iniciar a configuração, certifique-se de que possui os seguintes requisitos atendidos:

- **Conta ativa na AWS**
  > **O que é AWS?**
  > Amazon Web Services (AWS) é uma plataforma de computação em nuvem que fornece infraestrutura sob demanda, como servidores, armazenamento e bancos de dados, permitindo que desenvolvedores criem e escalem aplicações rapidamente.

- **WSL instalado no PC (caso esteja utilizando Windows)**
  > **O que é WSL?**
  > O Windows Subsystem for Linux (WSL) permite rodar um ambiente Linux diretamente no Windows sem precisar de uma máquina virtual, facilitando o desenvolvimento e administração de servidores remotos.

- Guia de instalação do Ubuntu no Windows: [How to install Ubuntu on Windows 10 from Microsoft Store](https://www.youtube.com/watch?v=La8jIAAANSA&t=203s)
- Documentação do WSL: [Documentação do Subsistema Windows para Linux | Microsoft Learn](https://learn.microsoft.com/pt-br/windows/wsl/)

> **Observação:** Minha console está em inglês. Caso os nomes dos menus estejam diferentes na sua, pode ser devido ao idioma configurado.

---

# Etapa 1: Configuração do Ambiente ☁️

## 1. Criar VPC
A **Virtual Private Cloud (VPC)** é uma rede virtual isolada dentro da AWS onde serão configurados os recursos do projeto.

### Passos para criação:

1. No console da tela inicial da AWS, vá até a lupa e pesquise por "VPC" e clique em "Your VPCs".

   ![image01](assets/img01.png)

2. Irá abrir a página de gerenciamento de VPCs. Clique em **"Create VPC"**.
   
   ![image02](assets/img02.png)

3. Nas configurações:
   - Selecione **"VPC and more"**.
   > Essa opção permite criar não apenas uma VPC, mas também configurar automaticamente subnets, tabelas de roteamento e gateways necessários para a comunicação da rede. Ao escolher essa opção, a AWS ajuda a configurar um ambiente de rede mais completo sem precisar definir manualmente cada componente.
   - Marque "Auto-generate"
   > Quando essa opção está ativada, a AWS gera automaticamente os CIDR blocks e distribui as subnets nas Availability Zones da região escolhida. Isso simplifica a configuração inicial, garantindo que os endereços IP fiquem organizados corretamente dentro da VPC.
   - Defina um nome para sua VPC (exemplo: "project")
   - Defina o **IPv4 CIDR block** como **10.0.0.0/16**
   > 
   > **O que é IPv4 CIDR block?**
   > CIDR (Classless Inter-Domain Routing) é um método para definir intervalos de endereços IP. O bloco **10.0.0.0/16** significa que a VPC pode ter até 65.536 endereços IP disponíveis dentro deste intervalo.
   
   ![image03](assets/img03.png)

4. Nas configurações:
   - Selecione **No IPv6 CIDR block**
   > **O que é IPv6 CIDR block?**
   > Diferente do IPv4, o IPv6 usa um esquema de endereçamento maior e mais complexo. No projeto, optei não utilizar IPv6.
   
   - **Tenancy**: "Default"
   > **O que é Tenancy?**
   > Define como os recursos da AWS são alocados. A opção "Default" significa que a VPC compartilhará a infraestrutura física da AWS com outros usuários, reduzindo custos.
   
   - **Número de AZs (Availability Zones)**: 2
   - Customizei para "us-east-1a" (Virgínia) e "us-east-1b" (Ohio)
   
   > **O que são Availability Zones (AZs)?**
   > Availability Zones são localizações distintas dentro de uma região AWS. Cada região possui múltiplas AZs, que são centros de dados isolados fisicamente, garantindo maior disponibilidade e tolerância a falhas.

   ![image04](assets/img04.png)

5. Como o projeto exige, configurei **duas subnets públicas e duas privadas**.
   
   > **O que são subnets públicas e privadas?**
   > - **Subnets públicas**: Permitem comunicação direta com a internet através de um Internet Gateway.
   > - **Subnets privadas**: Ficam isoladas da internet e precisam de um NAT Gateway para acessar recursos externos.
   
   ![image05](assets/img05.png)

6. Configure o CIDR block das subnets como **10.0.0.0/20**.
   
   > **O que significa CIDR block das subnets como 10.0.0.0/20?**
   > Cada subnet recebe uma parte do bloco de endereços da VPC. **/20** significa que cada subnet pode ter até 4.096 endereços IP disponíveis.
   
   ![image06](assets/img06.png)

7. Configure as opções adicionais:
   - **NAT Gateways ($):** "None"
   
   > **O que é NAT Gateway?**
   > Um NAT Gateway permite que instâncias em subnets privadas acessem a internet sem serem diretamente acessíveis por ela.
   
   - **VPC Endpoints:** Selecione "S3 Gateway"
   
   > **O que são VPC Endpoints e S3 Gateway?**
   > Um **VPC Endpoint** permite que recursos dentro da VPC se comuniquem com serviços da AWS sem passar pela internet. O **S3 Gateway** é um tipo de endpoint usado para acessar o Amazon S3 de forma segura e eficiente.
   
   - **Habilitar DNS:** Marque as opções "Enable DNS hostnames" e "Enable DNS resolution"
   
   > **O que é DNS e por que habilitá-lo?**
   > O DNS (Domain Name System) traduz endereços IP em nomes legíveis. Habilitá-lo permite que instâncias dentro da VPC se comuniquem mais facilmente usando nomes ao invés de IPs.
   
   - **Tags:** Não adicionei tags extras
   
   > **O que são Tags?**
   > Tags são rótulos personalizáveis usados para organizar e identificar recursos dentro da AWS, facilitando a administração.
   
8. Clique em **"Create VPC"** para finalizar a configuração.
   
   ![image07](assets/img07.png)

9. O preview final ficará assim:
   
   ![image08](assets/img08.png)

---

## Criar Chave (Key Pairs)  

As **Key Pairs** (pares de chaves) são utilizadas para acessar a instância EC2 com segurança via SSH. Elas consistem em:  
- **Chave pública**: Fica armazenada na AWS e é associada à instância.  
- **Chave privada**: Deve ser baixada e armazenada localmente pelo usuário. Ela é necessária para autenticação SSH.  

> ⚠️ **Atenção**: Se você perder a chave privada, **não poderá acessar sua instância EC2**.  

### Criando a Key Pair  

1. No menu da AWS, clique no ícone de pesquisa e digite **"Key Pairs"**. Em seguida, clique na opção correspondente.  

   ![image09](assets/img09.png)

2. Clique em **"Create key pair"**.  

   ![image10](assets/img10.png)

3. Configure a chave com as seguintes opções:  
   - **Nome**: Escolha um nome para a chave. No exemplo, usei `"key-project"`.  
   - **Tipo de chave**: Selecione **"RSA"**, pois é um dos algoritmos de criptografia mais utilizados para SSH.  
   - **Formato da chave privada**: Escolha **".pem"**. Esse formato é necessário para conexões SSH no Linux e Mac.  

4. Clique em **"Create key pair"**.  

5. O download da chave privada será feito automaticamente. 
> ⚠️ **Guarde esse arquivo em um local seguro** e LEMBRE do lugar que você
a armazenar, pois ele será necessário para acessar a instância EC2 posteriormente.  

6. Não adicionei nenhuma tag

   ![image11](assets/img11.png)

---

## Criar Security Group  

Os **Security Groups** atuam como **firewalls virtuais** para as instâncias EC2. Eles controlam o tráfego de entrada e saída, permitindo apenas conexões autorizadas.  

### Criando o Security Group  

1. No menu da AWS, clique no ícone de pesquisa e digite **"Security Groups"**. Em seguida, clique na opção correspondente.  

   ![image12](assets/img12.png)

2. Clique em **"Create security group"**.  

   ![image13](assets/img13.png)

3. Configure os seguintes campos:  
   - **Nome**: Escolha um nome para o grupo. No exemplo, utilizei `"security-group-project"`.  
   - **Descrição**: Insira uma breve descrição. No meu exemplo utilizei
   `"teste"`.  
   - **VPC**: Selecione a **VPC criada anteriormente**. No exemplo, `"project-vpc"`.  

   ![image14](assets/img14.png)

### Configuração das Regras de Entrada (Inbound Rules)  

As **Inbound Rules** determinam quais conexões externas podem acessar a instância.  

4. Clique em **"Add Rule"** para adicionar regras de entrada.  

   ![image15](assets/img15.png)
   
5. Adicione as seguintes regras:  

   - **SSH (porta 22)**  
     - **Tipo**: SSH  
     - **Protocolo**: TCP  
     - **Port Range**: 22  
     - **Source (Origem)**: **My IP** (recomendado por causa da seguraça)  
     > Permite que **apenas o seu IP atual** acesse a instância via SSH. Isso evita acessos indesejados.  

   - **HTTP (porta 80)**  
     - **Tipo**: HTTP  
     - **Protocolo**: TCP  
     - **Port Range**: 80  
     - **Source (Origem)**: **My IP** (inicialmente por causa da segurança,
     após todas as configurações, deixaremos como **0.0.0.0/0**)  
     > Permite apenas o seu IP acessar o servidor web (por enquanto).
     Após todas as configurações será necessário mudar a origem do HTTP para
     **0.0.0.0/0**, permitindo que qualquer usuário da internet acesse a página hospedada na instância.   
 
   ![image16](assets/img16.png)
   
### Configuração das Regras de Saída (Outbound Rules)  

As **Outbound Rules** definem quais conexões **a instância pode iniciar** para outros servidores.  

7. Em **Outbound Rules**, configure:  
   - **Tipo**: `"All traffic"`  
   - **Protocolo**: `"All"`  
   - **Port Range**: `"All"`  
   - **Destination**: `"Anywhere - IPv4 (0.0.0.0/0)"`  

   ![image17](assets/img17.png)

   > Isso permite que a instância **acesse qualquer serviço na internet**, como atualizações de pacotes e APIs externas.  

8. **Tags (Opcional)**  
   Não adicionei nenhuma tag.
   - Se desejar, adicione **tags** para melhor organização.  
   > As tags são úteis para identificar recursos, especialmente em ambientes grandes com várias instâncias.  

9. Clique em **"Create security group"**.  

   ![image18](assets/img18.png)

## Criar Instância EC2

# Etapa 2: Configuração do Servidor Web

<p align="center">
  <br>
  <img src="assets/compassUol-logo.svg" alt="CompassUOL Logo" width="250">
</p>

