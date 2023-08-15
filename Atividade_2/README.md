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

## Criando a primeira instância

Agora, dentro da console da AWS, vamos criar uma nova instância seguindo os mesmos passos da **Atividade_1**. A diferença, é que vamos anexar o arquivo update.sh no **user_data** em opções avançadas, e, nesse primeiro momento, vamos habilitar a atribuição automática de ipv4 público à intância, para que possamos acessa-lá via ssh sem a necessidade de atribuir um Elastic IP

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