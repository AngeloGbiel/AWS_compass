# _Atividade sobre Docker na AWS_
### Criando um arquivo .sh
Antes de começar a configuração dentro da AWS, primeiro vamos criar um arquivo de ShellScript para a instalação automática no **user_data** dentro das instâncias EC2
Para isso, vamos criar um arquivo chamado **update.sh** e colocar as seguintes configurações:
```sh
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker.service
systemctl enable docker.service
echo "$(systemctl status docker.service)" > /tmp/log_docker.txt
usermod -aG docker ec2-user
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "$(docker-compose version)" >> /tmp/log_docker.txt
```
Basicamente, esse arquivo vai instalar o docker e o docker-compose (últimas versões) dentro da nossa instância EC2, anotando os logs de instalação dentro de um arquivo chamado **log_docker.txt** localizado no diretório **/tmp**

## Criando uma VPC

Antes de executar uma instância, precisamos criar e configurar uma VPC, onde nela teremos:
- 2 subnet pública 
- 2 subnets privadas
- Nat gateway configurado na subnet pública (para esse exemplo, vamos utilizar a **us-east-1a**)

Para criar um nova VPC, vamos:
- Ir nos serviços de VPC dentro da AWS
- Ir em _Suas vpcs_ e depois em Criar VPC_
- Selecionar a opção **VPC e muito mais**
- Vamos deixar tudo padrão (2 AZs, 2 subnets públicas e 2 subnets privadas)
- Vamos habilitar o Gateways NAT em apenas uma AZ (que nesse caso será na **us-east-1a**)
- Depois vamos em _Criar VPC_

## Criando a primeira instância

Agora, dentro da console da AWS, vamos criar uma nova instância seguindo os mesmos passos da **Atividade_1**. A diferença, é que vamos anexar o arquivo update.sh no **user_data** em opções avançadas, e, nesse primeiro momento, vamos habilitar a atribuição automática de ipv4 público à intância, para que possamos acessa-lá via ssh sem a necessidade de atribuir um Elastic IP

**IMPORTANTE**: essa instância será a que realizaremos o bastion Host caso haja a necessidade, e para isso, precisaremos criar essa intância na AZ configurada com Nat gateway, ou seja, a AZ **us-east-1a**

## montagem do EFS

Vamos no serviço de EFS dentro da console da amazon (criada na Atividade_1), e, dessa vez vamos efetuar uma montagem permanente da EC2.
Uma vez conectado a instância, vamos executar o seguinte comando:
```sh
sudo vim /etc/fstab
```
O arquivo **fstab** gerencia como e onde as partições e dispositivos de armazenamento devem ser montados, e vamos usar para montar de forma permanente o EFS da aws
Para isso, devemos adcionar a seguinte instrução no arquivo:
```sh
<mount-target-DNS:/> <efs-mount-point> nfs4 <options> 0 0
```
Onde:
- **mount-target-DNS**: DNS do seu efs
  - Ex: fs-06fbc125e54a40e59.efs.us-east-1.amazonaws.com:/
- **efs-mount-point**: é o ponto de montagem
  - Ex: /home/ec2-user/efs/
- **options**: as opções de montagem
  - ex: nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport

Após isso, podemos usar o comando **sudo mount -a** para montar o efs sem a necessidade de reiniciar a máquina, e podemos executar o comando **df -h** para visualizarmos o ponto de montagem criado
Nesse ocasião, não criamos o diretório **efs**, porém, quando executamos o comando de montagem, o diretório é cirado automaticamente
Após isso, vamos criar o diretório efs com o comando **mkdir efs** dentro do diretório do usuário, e então podemos usar o comando **sudo mount -a** para montar o efs sem a necessidade de reiniciar a máquina, e podemos executar o comando **df -h** para visualizarmos o ponto de montagem criado

Para evitar problemas com questões de permissão, para essa atividade, vamos executar o seguinte comando para permitir a leitura/gravação do usuário ec2-user:
```sh
sudo chown ec2-user efs/
```
Se executarmos o comando **ls -la** veremos que agora o usuário _ec2-user_ é o dono desse diretório

## Arquivo docker-compose e configuração do wordpress

Uma vez montado, podemos entrar no diretório compartilhado (cd efs/) e criar um arquivo de configuração do docker-compose para subir uma aplicação wordpress.
Vamos executar o comando **vim docker-compose.yml** exatamente dessa forma, e criaremos o seguinte código

```yml
version: "3.9"
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - ./config/php.conf.uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
      - ./wp-app:/var/www/html
    ports:
      - 80:80
    restart: always
```

Esse código irá baixar a imagem **wordpress**, anexar o volume efs como diretório estático dentro do container wordpress, e definir a porta 80 para expor a nossa aplicação

Depois disso, podemos desconectar dessa instância. 

## Criando um template

Quando formos trabalhar com Auto scaling, teremos que utilizar uma **instância modelo** para o _scaling out_ (ajusta sua capacidade horizontalmente), ou seja, criando novas instâncias com base no **modelo de execução**
Para isso, primeiro vamos gerar uma **AMI** da instância que acabamos de criar:
- Selecionar a instância criada
- Ir em **ações** 
- Selecionar **imagem e modelos** e depois **criar imagem**

Após isso, na seção **instâncias**, vamos em _modelo de execução_