repo="The-DevOps-Journey-101"
userid=$(id -u)
echo "corroborando permiso de usuario"
if [ "${userid}" -ne 0 ];
then
    echo "El Scrip debe ejecutarse con un usuario root"
    exist
fi

echo "========================================"
apt-get update
echo "El servidor se esta actualizando"
if dpkg -l |grep -q apache2;
then
    echo "Apache instalado en sistema"
else
    echo "instalando Apache2"
        apt install apache2 -y
        apt install -y php libapache2-mod-php php-mysql
        systemctl start apache2
        systemctl enable apache2
        systemctl status apache2
fi
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
        mysql -e "MariaDB > CREATE DATABASE ecomdb;
        MariaDB > CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
        MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
        MariaDB > FLUSH PRIVILEGES;"

cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

lmysql < db-load-script.sq
fi
echo "====================================="
echo "cargando repositorio"
if [ -d $repo ];then
    echo "el archivo $repo existe"
else
    git clone https://github.com/roxsross/$repo.git
    echo "Instalando y configruando web"
    cp -r $repo/CLASE-02/lamp-app-ecommerce/* /var/www/html
    mv /var/www/html/index.html /var/www/html/index.html.bkp

fi
    sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
        # <?php

        #                 $link = mysqli_connect('172.20.1.101', 'ecomuser', 'ecompassword', 'ecomdb');

        #                 if ($link) {
        #                 $res = mysqli_query($link, "select * from products;");
        #                 while ($row = mysqli_fetch_assoc($res)) { ?>
curl http://localhost

systemctl reload apache2