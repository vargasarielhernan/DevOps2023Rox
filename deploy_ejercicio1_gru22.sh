repositorio="bootcamp-devops-2023"
userid=$(id -u)
echo "corroborando permiso de usuario"
if [ "${userid}" -ne 0 ];
then
    echo "El Scrip debe ejecutarse con un usuario root"
    exist
fi

echo "========================================"
sudo apt-get update
echo "El servidor se esta actualizando"
if dpkg -l |grep -q apache2;
then
    echo "Apache instalado en sistema"
else
    echo "instalando Apache2"
        apt install apache2 -y
        apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl
        systemctl start apache2
        systemctl enable apache2
        systemctl status apache2
fi
php -v

sudo sed -i 's/DirectoryIndex index.php index.html/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.html/g' /etc/apache2/mods-enabled/dir.conf
sudo systemctl reload apache2
echo "====================================="
echo "Verificando git"

if dpkg -l |grep -q git;
then
    echo "Git instalado en sistema"
else
    echo "instalando git"
        apt install -y git
fi
echo "====================================="
echo "Verificando curl"

if dpkg -l |grep -q curl;
then
    echo "Curl instalado en sistema"
else
    echo "instalando curl"
        apt install -y curl
fi
echo "====================================="
echo "verificando mariadb"
if dpkg -l |grep -q mariadb-server;
then
    echo "mariadb instalado en sistema"
else
    echo "instalando mariadb"
        apt install -y mariadb-server
        systemctl start mariadb
        systemctl enable mariadb
        systemctl status mariadb
mysql -e "MariaDB > CREATE DATABASE devopstravel;
MariaDB > CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;"
mysql < database/devopstravel.sql

fi
echo "====================================="
echo "cargando repositorio"
if [ -d $repositorio ];then
    echo "el archivo $repositorio existe"
    cd $repositorio
    git pull origin clase2-linux-bash
else
    git clone https://github.com/roxsross/$repositorio.git
    echo "Instalando y configruando web"
    git checkout clase2-linux-bash
    git pull origin clase2-linux-bash
cp -r $repositorio/* /var/www/html/
mv /var/www/html/index.html /var/www/html/index.html.bkp
mv /var/www/html/index.php /var/www/html/index.php
    
fi
 sudo systemctl reload apache2
 curl localhost/info.php
 browser http://localhost/info.php

  curl localhost
 browser http://localhost

systemctl reload apache2