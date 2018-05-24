#!/bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mysql-server-5.5
sudo apt-get install monit -y
echo "127.0.0.1 $HOSTNAME" | sudo tee -a   /etc/hosts

sudo /etc/init.d/monit start
sudo sed -i 's/  set daemon 120/  set daemon 15/g' /etc/monit/monitrc
echo "set httpd port 2812
    use address $(curl -s http://169.254.169.254/latest/meta-data/public-hostname)  # only accept connection from localhost
    allow 0.0.0.0/0.0.0.0        # allow localhost to connect to the server and
    allow admin:monit  " | sudo tee -a /etc/monit/monitrc

echo ' check process apache with pidfile /run/apache2/apache2.pid
    start program = "/etc/init.d/apache2 start" with timeout 60 seconds
    stop program  = "/etc/init.d/apache2 stop" ' | sudo tee -a /etc/monit/monitrc

echo ' check process mysql with pidfile /run/mysqld/mysqld.pid 
    start program = "/etc/init.d/mysql start" with timeout 60 seconds
    stop program  = "/etc/init.d/mysql stop" ' | sudo tee -a /etc/monit/monitrc

sudo monit reload
sudo /etc/init.d/monit stop
sudo /etc/init.d/monit start
