#/bin/bash
apt update && apt install apache2 -y
cat /var/www/html/index.html > "This is apache2-app"