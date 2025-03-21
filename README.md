<p align="center">
  <img src="assets/projeto-logo.png" alt="Projeto Logo" width="600">
</p>
<br>

# Documentação do Projeto DevSecOps ☁️

## Ferramentas Úteis

### ZoomIt da Microsoft para Prints de Tela com Setas
Para capturar telas com anotações, utilizei o ZoomIt da Microsoft.

- Documentação e instalação do ZoomIt: [ZoomIt - Sysinternals | Microsoft Learn](https://learn.microsoft.com/pt-br/sysinternals/downloads/zoomit)

## Pré-Requisitos
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

# Etapa 1: Configuração do Ambiente

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

## Criar Chave (Key pairs)
No menu da AWS no ícone de pesquisar procure por "Key pairs" e depois clique.

![image09](assets/img09.png)

Clique em "Create key pair"

![image10](assets/img10.png)

Dê um nome para a chave, no meu exemplo foi "key-project"
No tipo selecione "RSA"
Selecione o formato ".pem"
Clique em "create key pair"
Salve a chave e lembre o local em que vc a guardou

![image11](assets/img11.png)

## Criar Security Group
No menu da AWS no ícone de pesquisar procure por "security groups" e depois clique.

![image12](assets/img12.png)

Clique em "Create security group"

![image13](assets/img13.png)

Dê um nome ao security group, no meu exemplo "security-group-project"
Dê uma descrição, no meu exemplo "teste"
Em VPC, selecione a VPC já criada anteriormente, no meu caso "project-vpc"

![image14](assets/img14.png)

Em Inbound rules crie em add rule
Nós iremos criar duas portas:
SSH 22
HTTP 80
Ambas serão configuradas como MyIP
Após tudo pronto, abriremos a porta http para 0.0.0.0, enquanto isso não é
recomendado por causa de segurança (explique melhor)

![image15](assets/img15.png)

Em outbound rules em Type selecione "All traffic" e em Destination "Anywhere-IPv4"

![image16](assets/img16.png)

Nas Tags opcionais não adicionei nenhuma.
Depois clique em "Create security group"

![image17](assets/img17.png)

TESTE1

![image18](assets/img18.png)

## Criar Instância EC2

# Etapa 2: Configuração do Servidor Web

<p align="center">
  <br>
  <img src="assets/compassUol-logo.svg" alt="CompassUOL Logo" width="250">
</p>

