## _Configuração inicial - virtual machine_

Antes de iniciarmos, primeiramente vamos realizar a instalação da nossa máquina virtual para que todos os processos realizados sejam feitos de forma segura e sem qualquer interferência em sua máquina real.
Na prática, usaremos o Oracle vm, disponível no site https://www.virtualbox.org/, porém pode ser utilizado outros softwares de criação de uma máquina virtual de sua preferência. 
Após a instalação, vamos efetuar o download da distribuição Oracle Linux no site https://yum.oracle.com/oracle-linux-isos.html (versão 8.6 ou 8.7 para essa prática).
Dentro do software de criação de uma máquina virtual, iremos ir na opção “Novo” (ou o atalho ctrl+n em seu teclado) e atribuir um nome (Oracle Linux 8.6 por exemplo), a pasta onde nossa máquina virtual será salva, selecionar a imagem ISO do Oracle Linux que baixamos e marcar a opção “Pular instalação desassistida” para que a configuração possa ser realizada de forma manual (como idioma, localização, nome de usuário, senha, etc) e evitar possíveis erros futuros. Clique em “Próximo” e configure as opções de “Hardware” de acordo com as configurações de sua máquina, e nesse primeiro momento deixaremos a opção de EFI desabilitada. Clique em próximo e crie um novo disco rígido virtual (15 a 20 GB já é o suficiente para a prática) e deixe a opção “pré-alocar o tamanho total” desativada. Clique no próximo e depois em finalizar. 


## Configuração de internet

Antes de iniciarmos a instalação da ISO, vamos configurar o acesso a internet da nossa VM. Com nossa máquina virtual selecionada, vamos em configurações (atalho ctrl+s do seu teclado), redes, e mudaremos de “NAT” para “Placa em modo Bridge”

- No modo NAT, a VM é configurada para usar a conexão de rede do host como intermediário para se comunicar com a rede externa, não possibilitando o acesso via ssh 
- No modo Bridge, a VM é configurada para se conectar diretamente à rede física externa, como se fosse um dispositivo físico na rede, possibilitando o acesso via ssh

## Instalação do Linux

Após a criação da máquina virtual e configuração da rede, vamos selecionar nossa máquina virtual e vamos em iniciar (atalho ctrl + t no teclado), e esperar até a tela de “welcome to oracle linux” e selecionar o idioma que iremos prosseguir (para a prática, iremos usar o idioma em **inglês**) 
As configurações no **Installation Summary**, faremos as seguintes configurações:
- Keyboard em português (ou idioma do seu teclado).
- Time & Date para sua região.
- Software Selection: vamos selecionar o “Server” para utilizarmos o linux somente com a interface gráfica.
- Network & hostname:  Vamos dar acesso a Ethernet (de OFF para ON).
- Root password: criar uma senha de root.
- User Creation: criar um usuário comum com uma senha, e marcar a opção “Make this user administrator”.
- Em installation destination vamos selecionar o disco que criamos.
- Após isso, vamos em “Begin installation” e esperar a instalação terminar.

## Acessando a máquina via SSH (Secure Socket Shell)

Toda a prática será feita acessando a máquina virtual via SSH, e para isso, é importante que a configuração da rede esteja como modo **Bridge** para que consigamos ter acesso a ela. Caso a rede esteja configurada de forma correta, ao executar o comando **ip a** teremos acesso ao ip da nossa máquina (nesse caso, o endereçamento ip será parecido com esse **192.168.0.0**) que é atribuído automaticamente pelo DHCP.
Para acessarmos essa máquina via SSH, temos duas formas: pelo putty (para sistemas linux, windows e mac), e pelo próprio terminal linux. 
Na interface do putty, iremos colocar o endereço ip (que é exibido quando utilizamos o comando **ip a**) e depois em “open”
No terminal linux, precisamos ter em mente não apenas o ip da máquina, mas também o hostname, para isso, dentro da nossa máquina virtual, vamos executar o comando hostname. Sabendo o hostname e o ip da máquina, dentro do nosso terminal, vamos executar o seguinte comando: ssh hostname@ip (ex: ssh user1@192.168.0.104) 
Uma vez acessado a máquina, vamos executar o comando **yum update** (verifica se há atualizações disponíveis para os pacotes instalados) e **yum upgrade** (atualização de pacotes que tiveram alterações em suas dependências)

## Instalando o Command Line Interface (CLI)

Temos várias formas de criar e gerenciar aplicações dentro da AWS, uma delas é por meio da linha de comando do nosso terminal, e para isso, precisamos efetuar a instalação do AWS CLI dentro do nosso linux 

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```


Para sabermos que a instalação foi realizada com sucesso, podemos executar o comando:
```sh
aws –version
```

## Permitindo acesso a AWS CLI
Para gerenciar as aplicações dentro da AWS por meio da CLI, vamos precisar fazer algumas configurações:
- Na console aws, vamos no serviço de IAM (Identity and Access Management)
- Na seção “Gerenciamento de acesso”, vamos em “usuários” e depois em “adicionar usuário”
- Vamos dar um nome e prosseguir
- Vamos anexar a política “AdministratorAccess” diretamente a esse usuário
- No termino da criação do usuário, vamos selecioná-lo e depois vamos em “credenciais de segurança” e “criar chave de acesso”
- Vamos escolher a opção “CLI” e prosseguir	
- Vamos baixar o arquivo .cvs contendo a chave de acesso e a chave pública (guarde esse arquivo de forma segura)
- Dentro da nossa máquina virtual, vamos executar o comando **aws configure**
- Vamos passar a chave de acesso, chave privada, a região “us-east-1” e o formato “JSON”.
- Após isso, teremos acesso a AWS por meio do CLI da máquina virtual

## Criando uma chave ssh

Para termos acesso as instância EC2 da AWS, vamos criar e configurar as chaves de acesso dentro da nossa máquina virtual (key pair)
```sh
ssh-keygen -t rsa -b 2048
cd .ssh
```
- ssh-keygen: cria duas chaves, uma pública e outra privada
- -t: tipo de chave que queremos criar (**rsa** é o tipo que a AWS utiliza, mas não precisa ser esse formato necessariamente)
- -b: quantidade de bits (2048)

A chave pública será enviada para a AWS enquanto a privada será usada para acessar as instâncias EC2.

**Para anexar a chave pública dentro da aws, vamos:**
- Navegar até o serviço de EC2, na seção rede e segurança (Network & Security) e procurar por “pares de chave” (ou key pair)
- Vamos em “ações” e depois em “importar par de chaves”
- Vamos colar o conteúdo da nossa **chave pública** e depois atribuir um nome
- A chave está pronta para ser usada dentro da aws

## Criando uma VPC

Antes de criarmos a instância, vamos navegar até os serviços de VPC dentro da aws. 
Em **suas VPCs** dentro da seção **Nuvem Privada Virtual**, vamos criar uma nova VPC
Escolheremos a opção “VPC e muito mais”
Colocaremos um nome (AWS_compass_project) e um bloco CIDR IPv4 (192.168.0.0/16), e deixar todas as outras opções como padrão

## Criando um grupo de segurança

Dentro do serviço de EC2, vamos na seção rede e segurança, e em “Security groups”
Vamos criar um novo grupo de segurança usando a VPC criado anteriormente, onde devemos nos preocupar somente com as **regras de entrada**. Vamos liberar as seguintes portas:
- **porta 22/tcp, serviço SSH**: acessar a instância via ssh
- **porta 80/tcp, serviço http**: permitir requisição via http
- **porta 443/tcp, serviço https**: permitir requisição via https
- **porta 2049/tcp/udp, serviço de nfs**: permitir o compartilhamento de pastas
- **porta 111 tcp e udp, serviço de Portmap**: usado especialmente para compartilhamento de arquivos
- Todos essas regras terão a configuração de origem para qualquer local-ipv4, porém, isso não é recomendado por questões de segurança

## Criando uma instância EC2 e anexando um “Elastic IP”

Dentro do serviço de EC2, vamos criar uma nova instância, seguindo as configurações abaixo:
- Criar 3 tags, a primeira chamada **Name**, com o valor **PB IFMT - UTFPR**, a segunda chamada **Project**, com o valor **PB IFMT - UTFPR** e a terceira chamada **CostCenter**, com o valor **C092000004**, e em **tipos de recursos** vamos anexar **instâncias** e **Volumes**
- Em imagens vamos selecionar **Amazon Linux 2 AMI (HVM) - kernel 5.10, SSH Volume Type**, e tem tipo de instância vamos selecionar a **t2.micro**
- Vamos escolher o par de chaves criado anteriormente
- Em configurações de rede vamos clicar em “editar”, e selecionar a VPC e o grupo de segurança que criamos anteriormente
- Em “Configurar armazenamento", vamos selecionar o **gp2** com 16 GB, e clicar em “Executar instância” 
- Agora, dentro da seção **rede e segurança**, vamos em IPs Elásticos e em **Alocar endereço ip Elastico**. É importante que o IP elástico esteja na mesma região da instância.
- Uma vez alocada, vamos selecionar nosso ip elástico, ir em **Ações**, e **associar endereço ip elástico** 
- Vamos selecionar nossa instância criada, e selecionar um endereçamento ip privado e depois em associar. 
- É **importante** ter em mente que, se houver um IP elástico alocado em sua conta, porém não associado a nenhuma instância ou outro serviço dentro da AWS, sua conta será taxada por isso. 

## Acessando a instância EC2 pela máquina virtual

Conectado a máquina virtual via ssh (terminal linux ou pelo putty), vamos realizar o acesso à instância ec2, mas antes, precisamos ter em mente três coisa:
- **Acesso a chave**: Se a chave foi criada pelo usuário e anexado dentro da aws, não é necessário atribuir nenhuma permissão, porém, se a chave foi criada na AWS e baixada pela console, há a necessidade de executar o comando **chmod 400 chave.pem** para conseguirmos acessar a instância
- **Nome de usuário**: Por padrão, o nome de usuário das instâncias EC2 é **ec2-user**
- **Endereçamento ip**: Para acessarmos a instância via ssh, o endereçamento ip que vamos utilizar é o IP elástico que configuramos anteriormente (que consequentemente é o ip público da instância)

Sabendo disso, vamos executar o comando
```sh
ssh -i chave.pem ec2-user@ip_elastico
```

## Baixando o APACHE 

Uma vez conectado a instância, vamos realizar o download do apache (que, nessa distribuição linux, se chama **httpd**)
```sh
sudo yum install -y httpd
sudo systemctl enable --now httpd.service
sudo systemctl status httpd
```
Após isso, podemos visualizar nosso servidor apache funcionando no nosso navegador, fazendo a requisição pelo ip público da nossa instância (IP elástico)

## Configurando o servidor apache

Dentro da instâncias, temos dois arquivos de configuração principal: o arquivo **/etc/httpd/conf/httpd.conf** que é responsável pela configuração geral do nosso servidor apache, e que aponta para o diretório **/var/www/html**, que é usado principalmente para armazenar arquivos e documentos relacionados a sites da web (arquivos html, php, etc)
Por padrão, ele vem vazio, porém posso criar um index.html e criar uma página simples como um “hello world” ou usar o git para clonar um repositório contendo um arquivo de html para dentro desse diretório.
Para isso, usei o arquivo de apache dentro do repositório https://github.com/AngeloGbiel/AWS_compass/tree/main/APACHE para isso (baixar o arquivo **web** e renomear para html dentro do diretório **/var/www**)
Após todas as configurações, é necessário reinicializar o serviço de apache, com o comando: 
```sh
sudo systemctl restart httpd.service
```

## Configurando o servidor nfs 

Basicamente, um servidor nfs (Network File System) é um sistema de arquivo distribuído que provê acesso transparente a discos remotos
Configurando um servidor nfs dentro de uma instância EC2:
- Ir até os serviços de EFS dentro da AWS e depois em **Criar sistema de arquivos**
- Vamos atribuir nome “NFS” (nome opcional) e escolher a VPC que criamos anteriormente
- Após criado, vamos selecionar o nosso sistema de arquivos, e na seção **rede** vamos aguardar até que o estado do destino esteja como **Disponível**
- Para termos acesso, vamos em **Gerenciar** e trocar o security group dos **Destinos de montagem** para o security group que criamos anteriormente
- Uma vez disponível, vamos em **anexar** no topo da página e copiar um dos dois comando que aparece para efetuar a montagem
- Agora, dentro da nossa instância ec2, vamos executar os seguintes comando:
  - cd : entrar dentro do diretório user
  - sudo mkdir efs
- Então, poderemos executar o comando de montagem, e esperar o processo de sincronização (posso executar o comando df -h para ver o ponto de montagem que acabamos de criar)
- (OPCIONAL: podemos montar uma outra instância EC2 e fazer o mesmo processo de montagem, e veremos a sincronização de arquivos: ao criar um arquivo em uma máquina, também irá aparecer na outra)

Após isso, vamos criar um outro diretório com o seu nome dentro do diretório efs (para a prática, irei utilizar o meu nome, Angelo)

## Validação do serviço apache

Há várias formas de visualizar se o servidor apache está ou não ativo, podemos por exemplo usar o comando **systemctl status httpd**, e teremos um status de “running”, ou, de uma forma mais prática, podemos executar o comando **systemctl is-active httpd**, onde o retorno desse comando será uma string dizendo se esse serviço está ativo (active) ou não (inactive), e será este comando que vamos utilizar em nosso Shell Script para validar se o serviço está ou não ativo de uma forma mais prática e rápida

**Criando um arquivo de shell script**

Esse arquivo pode ser criado em qualquer lugar do nosso sistema, mas para exemplo, irei criar um arquivo chamado “status.sh” (usando o vim) dentro do diretório **/home/ec2-user/**
Dentro do arquivo, colocaremos o seguinte código:

```sh
#!bin/bash

DIR="/home/ec2-user/efs/angelo"
STATUS=$(systemctl is-active httpd.service)
NAME=$(systemctl status httpd | head -n 1 | awk '{print $2}')
DATE=$(date +"%m/%d/%Y")
DAY=$(date +"%A")
HOURS=$(date +"%H:%M:%S")
INFORMATION="
--------log information--------------------------
        $DATE - $DAY
        $HOURS
        The service '$NAME' is currently $STATUS
"

# Faz uma validação, excluindo o arquivo "log_inactive" e criando um arquivo chamado "log_active"
if [[ "$STATUS" == "active" ]]; then
    if [[ -f "$DIR/log_inactive.txt" ]]; then
        rm -rf "$DIR/log_inactive.txt"
    fi
    if [[ -f "$DIR/log_active.txt"  ]]; then
        echo "$INFORMATION" >> "$DIR/log_active.txt"
    else
        touch "$DIR/log_active.txt"
        echo "$INFORMATION" >> "$DIR/log_active.txt"
    fi
# Faz uma validação, excluindo o arquivo "log_active" e criando um arquivo chamado "log_inactive"
else
    if [[ -f "$DIR/log_active.txt" ]]; then
        rm -rf "$DIR/log_active.txt"
    fi
    if [[ -f "$DIR/log_inactive.txt"  ]]; then
        echo "$INFORMATION" >> "$DIR/log_active.txt"
    else
        touch "$DIR/log_inactive.txt"
        echo "$INFORMATION" >> "$DIR/log_active.txt"
    fi
fi

# Faz o log estando inativo ou ativo
if [[ -f "$DIR/log_file.txt" ]]; then
        echo "$NAME - $DATE - $DAY - $HOURS - $STATUS" >> "$DIR/log_file.txt"
else
        touch "$DIR/log_file.txt"
        echo "$NAME - $DATE - $DAY - $HOURS - $STATUS" >> "$DIR/log_file.txt"
fi
exit 0
```
**Definição do código:** 
- É armazenado em variáveis informações como: diretório que serão salvos as informações; o status e o nome do serviço; a data, o dia e a hora; uma mensagem que será salvo usando as variáveis anteriores
- Verificar se o comando está ativo ou não, caso esteja ativo, irá criar uma posta de log com as informações da variável “INFORMATION” informando que o serviço está ativo, caso o contrário, será criado um outra arquivo dizendo que o serviço está inativo 
  - Cajo haja um arquivo dizendo que o serviço está ativo, e logo em seguida eu desativar o serviço e executar o script, esse arquivo será removido e criado outro, informando que o serviço está inativo
- Verificar se os repositórios existem, caso o contrário irá criar
- No final, todos as informações serão armazenados em um arquivo em forma de log, exibindo os horários em que o serviço estava ativo e inativo
   - httpd.service - 07/07/2023 - Friday - 11:40:04 - active 
   - httpd.service - 07/07/2023 - Friday - 11:45:04 - active 
   - httpd.service - 07/07/2023 - Friday - 11:50:04 - inactive 
   - httpd.service - 07/07/2023 - Friday - 11:55:04 - inactive

## Criando uma rotina de validação
Para criar uma rotina de validação a cada cinco minutos, efetuamos a seguinte configuração:
- usar o comando **/home/ec2-user/status.sh**
- editar o crontab com o comando **crontab -e**
- adicionar a rotina dentro do crontab: ***/5 * * * * /home/ec2-user/status.sh**
- Salvar e sair
- Usar o comando **sudo systemctl restart crond.service**

Após isso, poderemos observar que nossa rotina estará criada dentro do diretório **/home/ec2-user/nfs/angelo**
Podemos parar o serviço para visualizarmos as mudanças, com o comando:
```sh
sudo systemctl stop httpd.service
```

Lembrando que os arquivos de log estão na pasta compartilhada, ou seja, qualquer pessoa que tenha acesso áquela pasta poderá visualizá-los
