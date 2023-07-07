#!/bin/bash

##Instalando o Command Line Interface (CLI)

cd
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws –version

##configuração da CLI - permitir acesso pragmático

aws configure 
