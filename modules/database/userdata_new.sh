#!/bin/bash
set -e

LOG="/var/log/user-data.log"
STATUS_DIR="/var/www/html/status"

exec > >(tee -a $LOG) 2>&1

echo "====================================="
echo "MongoDB user-data started at $(date)"
echo "====================================="

# -------- Helpers --------
status() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $STATUS_DIR/status.txt
}

# -------- Prepare status page --------
mkdir -p /var/www/html
mkdir -p $STATUS_DIR
chmod -R 755 /var/www/html

echo "MongoDB instance bootstrapping..." > /var/www/html/index.html
echo "Initializing..." > $STATUS_DIR/status.txt

status "Bootstrap started"
status "MongoDB version = ${mongodb_version}"
status "Database name  = ${mongo_db_name}"

# -------- System packages --------
apt-get update -y
apt-get install -y curl gnupg nginx ca-certificates netcat-openbsd

status "System packages installed"

# -------- MongoDB install --------
status "Installing MongoDB"

curl -fsSL https://www.mongodb.org/static/pgp/server-${mongodb_version}.asc \
 | gpg --dearmor -o /usr/share/keyrings/mongodb-server-${mongodb_version}.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${mongodb_version}.gpg ] \
https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${mongodb_version} multiverse" \
| tee /etc/apt/sources.list.d/mongodb-org-${mongodb_version}.list

apt-get update -y
apt-get install -y mongodb-org

systemctl enable mongod
systemctl start mongod

status "MongoDB installed and started"

# -------- MongoDB config --------
status "Configuring MongoDB"

sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

cat >> /etc/mongod.conf <<EOF

security:
  authorization: enabled
EOF

systemctl restart mongod
sleep 5

status "MongoDB auth enabled"

# -------- Create admin user & database --------
status "Creating MongoDB admin user and database"

# First, create admin user without authentication
mongosh --eval "
use admin
db.createUser({
  user: '${mongo_admin_user}',
  pwd: '${mongo_admin_password}',
  roles: [
    { role: 'root', db: 'admin' }
  ]
})
"

# Then create the application database
mongosh -u ${mongo_admin_user} -p ${mongo_admin_password} --authenticationDatabase admin --eval "
use ${mongo_db_name}
db.init.insertOne({ createdAt: new Date(), message: 'Database initialized' })
"

status "MongoDB admin user created"
status "Database '${mongo_db_name}' initialized"

# -------- Verify MongoDB is ready --------
status "Verifying MongoDB is ready and accessible"

# Wait for MongoDB to be fully ready
sleep 10

# Test MongoDB is listening on all interfaces
netstat -tlnp | grep 27017 | tee -a $STATUS_DIR/status.txt

# Test local connection
mongosh --eval "db.runCommand('ping')" --authenticationDatabase admin -u ${mongo_admin_user} -p ${mongo_admin_password} | tee -a $STATUS_DIR/status.txt

# Show MongoDB status
systemctl status mongod --no-pager | tee -a $STATUS_DIR/status.txt

status "MongoDB verification completed"

# -------- Nginx status endpoint --------
status "Configuring Nginx"

cat > /etc/nginx/sites-available/status <<EOF
server {
  listen 80 default_server;
  server_name _;

  location /status/ {
    alias /var/www/html/status/;
    autoindex on;
  }

  location / {
    return 200 "MongoDB running\n";
    add_header Content-Type text/plain;
  }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/status /etc/nginx/sites-enabled/status
systemctl reload nginx

# -------- Expose logs --------
cp $LOG $STATUS_DIR/user-data.log
chown -R www-data:www-data /var/www/html

status "MongoDB ready"

echo "====================================="
echo "MongoDB user-data finished at $(date)"
echo "====================================="
