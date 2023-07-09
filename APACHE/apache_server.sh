#!/bin/bash

##baixando o servidor apache
sudo yum install -y httpd
sudo systemctl enable --now httpd.service
sudo systemctl status httpd

#
#   Arquivo de configuração do apache: /etc/httpd/conf/httpd.conf
#   Arquivo de html do apache: /var/www/html
#