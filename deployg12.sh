#!/bin/bash

#Variable
repo="bootcamp-devops-2023"
USERID=$(id -u)
USER_HOME=$(eval echo ~$SUDO_USER)
#colores
LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'




######################### #STAGE 1 ######################################


#Ejecucion del script como superusuario
if [[ ${USERID} -ne 0 ]]; then
        echo -e "\n${LRED} Ejecutar script como root${NC}"
	echo -e "\n${LRED} Saliendo del script...${NC}"
        exit 1
fi


#Paqueteria
echo "#########################################################"
apt update
echo -e "\n${LGREEN}El servidor se encuentra actualizado...${NC}"

##########INSTALACION MARIADB##################

if dpkg -l | grep -q mariadb; then
	echo -e "\n${LBLUE} MariaDB ya se encuentra instalado....${NC}"
else
	echo -e "\n${LBLUE} Instalando paquete Mariadb...${NC}"
        apt install mariadb -y
        systemctl start mariadb
        systemctl enable mariadb
	systemctl status mariadb

fi

if dpkg -l | grep -q apache2; then
	echo -e "\n${LBLUE} Apache2 ya se encuentra instalado....${NC}"
else
        echo "\m${LBLUE} Instalando paquete Apache2...${NC}"
        apt install apache2 -y
        sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl 
        systemctl start apache2
        systemctl enable apache2
	systemctl status apache2

fi

echo -e "\n${LBLUE} Apache2 instalando en funcionamiento....${NC}"


# Verificar si PHP está instalado
if command -v php > /dev/null 2>&1; then
    # PHP está instalado, mostrar la versión
    php -v
else
    # PHP no está instalado
    echo "PHP no está instalado en este sistema."
fi
############################ STAGE 2 ############################

#Configuracion BD
echo -e "\n${LBLUE} Configurando base de datos....${NC}"


if mysqlshow devopstravel > /dev/null 2>&1; then
    echo -e "\n${LGREEN}La base de datos devopstravel existe${NC}"
else
    # Crear la base de datos si no existe
    mysql -e "CREATE DATABASE devopstravel;"
    echo -e "\n${LBLUE}La base de datos devopstravel fue creada...${NC}"
fi

if mysql -e "SELECT user FROM mysql.user GROUP BY user;" | grep codeuser > /dev/null 2>&1; then
	echo -e  "\n${LGREEN}El usuario codeuser@localhost existe...${NC}"
else
	mysql -e "CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
	GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
	FLUSH PRIVILEGES;"
	echo -e "\n${LGREEN}El usuario codeuser@localhost fue creado...${NC}"
fi

#if [[ $?  -ne 0 ]]; then
#        echo -e "\n${LRED} Error en la configuracion de la bd | verifique que no exista la db${NC}"
#        echo -e "\n${LRED}Saliendo del script...${NC}"
#        exit 1
#
#fi

echo -e "\n${LBLUE} Base de datos creada y configurada....${NC}"


## Clonacion del repositorio
if [[ -d $repo ]]; then
    echo -e "\n${LBLUE} El repositorio ${repo} existe....${NC}"
    cd ${repo}
    git pull origin clase2-linux-bash
    
else
    echo -e "\n${LBLUE} Clonando el repositorio....${NC}"
    git clone https://github.com/roxsross/$repo.git
    cd ${repo}
    #git checkout clase2-linux-bash
    git pull origin clase2-linux-bash
    echo $repo
fi


#Ejecucion de script de carga de datos
mysql < ${USER_HOME}/$repo/app-295devops-travel/database/devopstravel.sql

echo -e "\n${LBLUE} Se ejecutó script para insertar datos a la db....${NC}"


#Copia de archivos webs
cp -r ${USER_HOME}/${repo}/app-295devops-travel/* /var/www/html
if [[ $?  -ne 0 ]]; then
        echo -e "\n${LRED} Error en la copia de archivos...${NC}"
        echo -e "\n${LRED}Saliendo del script...${NC}"
        exit 1
else
	echo -e "${LBLUE} Archivos copiados correctamente...${NC}"

fi

#Configuracion de contraseña de BD
sudo sed -i "s/\$dbPassword = \".*\";/\$dbPassword = \"codepass\";/" /var/www/html/config.php
echo -e "\n${LGREEN}Se configuró la contraseña de la BD...${NC}"

#Cambiar configuracion APACHE2
sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

#Testeo de aplicacion
systemctl restart apache2
if curl -I http://localhost/info.php > /dev/null 2>&1; then
        echo -e "\n${LGREEN} La pagina es funcional |codigo de salida 200|${NC}"
else
	echo -e "\n${LRED} La pagina no es funcional, revise su configuracion...${NC}"
	echo -e "\n${LRED} Saliendo del script...${NC}"
	exit 1
fi


######################## STAGE 3: [Deploy] ####################################
echo ""
echo -e "\n${LGREEN}Pruebe la pagina ingresando a: http://localhost o http://ip ${NC}"

####################### STAGE 4: [NOTIFY] #####################################

# Configura el token de acceso de tu bot de Discord
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
    echo "Grupo 12"
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

