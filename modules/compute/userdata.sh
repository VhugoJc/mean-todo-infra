#!/bin/bash
set -e

LOG="/var/log/user-data.log"
STATUS_DIR="/var/www/html/status"

exec > >(tee -a $LOG) 2>&1

echo "====================================="
echo "User-data started at $(date)"
echo "====================================="

# Prepare web root early
mkdir -p /var/www/html
mkdir -p $STATUS_DIR
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Visible proof
echo "User-data running at $(date)" > /var/www/html/index.html
echo "Status initialized at $(date)" > $STATUS_DIR/index.html

status() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $STATUS_DIR/status.txt
}

status "Bootstrap started"
status "github_repo_url = ${github_repo_url}"
status "frontend path   = frontend"

# System
apt-get update -y
apt-get install -y curl git nginx ca-certificates

# Node.js
status "Installing Node.js LTS"
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

node -v
npm -v

# Angular CLI
npm install -g @angular/cli

# Nginx
systemctl enable nginx
systemctl start nginx
rm -f /etc/nginx/sites-enabled/default

# Nginx proxy to Angular
cat > /etc/nginx/sites-available/angular <<EOF
server {
  listen 80 default_server;
  server_name _;

  location /status/ {
    alias /var/www/html/status/;
    autoindex on;
  }

  location / {
    proxy_pass http://localhost:4200;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
  }
}
EOF

ln -s /etc/nginx/sites-available/angular /etc/nginx/sites-enabled/angular
systemctl reload nginx

# Clone repo
status "Cloning repository"
cd /opt
rm -rf app
git clone ${github_repo_url} app

cd /opt/app/frontend
status "Inside frontend directory"
ls -la | tee -a $STATUS_DIR/status.txt

# Install deps
status "Installing npm dependencies"
npm install

# Run Angular (background, simple)
status "Starting Angular dev server"
nohup ng serve --host 0.0.0.0 --port 4200 > /var/log/angular.log 2>&1 &

# Expose logs
cp $LOG $STATUS_DIR/user-data.log
cp /var/log/angular.log $STATUS_DIR/angular.log 2>/dev/null || true

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

status "Angular dev server started"

echo "====================================="
echo "User-data finished at $(date)"
echo "====================================="
