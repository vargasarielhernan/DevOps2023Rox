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
    git pull origin clase2-linux-bash
else
    echo "Instalando y configruando web"
    git clone https://github.com/roxsross/$repositorio.git
    git checkout clase2-linux-bash
    git pull origin clase2-linux-bash
echo $repositorio
    
fi
echo "====================================="
cp -r /home/ariel/DevOps2023Rox/bootcamp-devops-2023/app-295devops-travel/* /var/www/html/
mv /var/www/html/bootcamp-devops-2023/app-295devops-travel/index.html /var/www/html/index.html.bkp
#mv /var/www/html/bootcamp-devops-2023/app-295devops-travel/index.php /var/www/html/index.php
 sudo systemctl reload apache2
 curl localhost/info.php

 curl localhost
 navegador http://localhost

systemctl reload apache2

DISCORD="https://discord.com/api/webhooks/1169002249939329156/7MOorDwzym-yBUs3gp0k5q7HyA42M5eYjfjpZgEwmAx1vVVcLgnlSh4TmtqZqCtbupov"

# Verifica si se proporcionó el argumento del directorio del repositorio
#if [ $# -ne 1 ]; then
#  echo "Uso: $0 <ruta_al_repositorio>"
#  exit 1
#fi

# Cambia al directorio del repositorio
#cd "$1"

# Obtiene el nombre del repositorio
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL=$(git remote get-url origin)
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)

# Verifica si la respuesta es 200 OK (puedes ajustar esto según tus necesidades)
if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
  # Obtén información del repositorio
    DEPLOYMENT_INFO2="Despliegue del repositorio $REPO_NAME: "
    DEPLOYMENT_INFO="La página web $WEB_URL está en línea."
    COMMIT="Commit: $(git rev-parse --short HEAD)"
    AUTHOR="Autor: $(git log -1 --pretty=format:'%an')"
    DESCRIPTION="Descripción: $(git log -1 --pretty=format:'%s')"
else
  DEPLOYMENT_INFO="La página web $WEB_URL no está en línea."
fi

# Obtén información del repositorio


# Construye el mensaje
MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"

# Envía el mensaje a Discord utilizando la API de Discord
curl -X POST -H "Content-Type: application/json" \
     -d '{
       "content": "'"${MESSAGE}"'"
     }' "$DISCORD"