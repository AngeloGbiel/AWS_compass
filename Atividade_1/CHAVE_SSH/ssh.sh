#!/bin/bash

##Criando uma chave ssh
cd 
ssh-keygen -t rsa -b 2048
cd .ssh

##Anexando a cheve dentro da AWS
cat id_rsa.pub ##Anexar de forma manual, copiando e colando o conteúdo da chave ssh pública
