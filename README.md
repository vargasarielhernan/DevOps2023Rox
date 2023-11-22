# DevOps2023Rox
Scrips de deploy de pagina web en ubuntu, usando apache2 mysql
Scriptg12.sh
Introducción:
Este script fue desarrollado por el grupo N°12 del bootcamp de DevOps. El script se utiliza para desplegar una aplicación web PHP en un servidor Linux, instalar los componentes necesarios, clona el repositorio de la aplicación, carga los datos en la base de datos y configura la aplicación para que se ejecute.

Desarrollo:
El script cuenta de 4 fases principales donde se desarrolla el despliegue de la pagina web usando un servidor apache en Linux, utilizando php para el backend y mariadb como base de datos. A continuación se desarrolla las siguientes etapas del script.
Primero ejecutamos el archivo deployg12.sh con el comando:
```
./deployg12.sh
```
STAGE 1: [Init]

Una vez iniciado el script verificara si somos usuario root con el siguiente comando:
```
#Ejecucion del script como superusuario
if [[ ${USERID} -ne 0 ]]; then
        echo -e "\n${LRED} Ejecutar script como root${NC}"
	echo -e "\n${LRED} Saliendo del script...${NC}"
        exit 1
fi
```
Si el usuario que ejecuta el script es root procede a verificar e instalar y actualizar los paquetes necesarios para realizar el despliegue de la aplicación.
Los paquetes necesarios para el funcionamiento de la pagina web son:
•	Apache
•	Php
•	Mariadb
•	Git
•	Curl

Para habilitar y Testear la instalación de los paquetes hacemos un if para preguntar si el paquete está instalado, en caso de que no se procede a instalarlo y configurarlo:
```
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
```
El siguiente paso es configurar la base de datos:
```
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
```
STAGE 2: [Build]

Clonar el repositorio de la aplicación:
Validar si el repositorio de la aplicación, si no existe realizar un git clone y si existe un git pull del repositorio.
Mover al directorio donde se guardar los archivos de configuración de apache /var/www/html/
Testear existencia del codigo de la aplicación.
```
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
```







Ajustar el config de php para que soporte los archivos dinamicos de php agregando index.php
Testear la compatibilidad -> ejemplo http://localhost/info.php
Si te muestra resultado de una pantalla informativa php , estariamos funcional para la siguiente etapa.
```
#Cambiar configuracion APACHE2
sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf
```
STAGE 3: [Deploy]

Es momento de probar la aplicación, recuerda hacer un reload de apache y acceder a la aplicacion DevOps Travel
```
#Testeo de aplicacion
systemctl restart apache2
if curl -I http://localhost/info.php > /dev/null 2>&1; then
        echo -e "\n${LGREEN} La pagina es funcional |codigo de salida 200|${NC}"
else
	echo -e "\n${LRED} La pagina no es funcional, revise su configuracion...${NC}"
	echo -e "\n${LRED} Saliendo del script...${NC}"
	exit 1
fi
```
STAGE 4: [Notify]

El status de la aplicacion si esta respondiendo correctamente o esta fallando debe reportarse via webhook al canal de discord #deploy-bootcamp
La informacion muestra : Author del Commit, Commit, descripcion, grupo y status con el siguiente código.
```
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
```
 Acceder a la aplicación web:
```
echo ""
echo -e "\n${LGREEN}Pruebe la pagina ingresando a: http://localhost o http://ip ${NC}"
```
