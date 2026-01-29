#!/bin/bash
set -e

LOG="/var/log/user-data.log"
STATUS_DIR="/var/www/html/status"
APP_DIR="/opt/app"

exec > >(tee -a $LOG) 2>&1

status() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $STATUS_DIR/status.txt
}

echo "=============================="
echo "User-data started $(date)"
echo "=============================="

#################################
# PREPARE WEB ROOT
#################################
mkdir -p /var/www/html $STATUS_DIR
chmod -R 755 /var/www/html
echo "Status page ready" > $STATUS_DIR/index.html

#################################
# SYSTEM PACKAGES
#################################
apt-get update -y
apt-get install -y curl git nginx ca-certificates netcat-openbsd

# Install MongoDB client tools
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt-get update -y
apt-get install -y mongodb-mongosh

status "System packages installed"

#################################
# NODE.JS + ANGULAR CLI
#################################
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs
npm install -g @angular/cli

node -v
npm -v

#################################
# NGINX
#################################
systemctl enable nginx
systemctl start nginx
rm -f /etc/nginx/sites-enabled/default

#################################
# CLONE REPOSITORY
#################################
status "Cloning repository"
rm -rf $APP_DIR
git clone ${github_repo_url} $APP_DIR

#################################
# TEST DATABASE CONNECTIVITY
#################################
status "Testing database connectivity"
echo "Attempting to connect to MongoDB at ${mongodb_private_ip}:27017"

# Test network connectivity with retries
MONGO_REACHABLE=false
for i in {1..10}; do
    if nc -z ${mongodb_private_ip} 27017 2>/dev/null; then
        status "✅ Port 27017 is reachable on attempt $i"
        MONGO_REACHABLE=true
        break
    else
        status "❌ Cannot reach port 27017 on attempt $i, retrying in 10 seconds..."
        sleep 10
    fi
done

# Test MongoDB connection
MONGO_CONNECTION_SUCCESS=false
if [ "$MONGO_REACHABLE" = "true" ]; then
    for i in {1..5}; do
        if timeout 5 mongosh "mongodb://${mongodb_private_ip}:27017/${mongo_db_name}" --eval "db.runCommand('ping')" --quiet >/dev/null 2>&1; then
            status "✅ MongoDB connection successful on attempt $i"
            MONGO_CONNECTION_SUCCESS=true
            break
        else
            status "❌ MongoDB connection failed on attempt $i, retrying in 5 seconds..."
            sleep 5
        fi
    done
fi

#################################
# BACKEND
#################################
status "Setting up backend"
cd $APP_DIR/backend

# Create .env file with database connection
status "Creating backend .env file"
cat > .env <<EOF
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://${mongodb_private_ip}:27017/${mongo_db_name}
MONGODB_HOST=${mongodb_private_ip}
MONGODB_PORT=27017
MONGODB_DATABASE=${mongo_db_name}
CORS_ORIGIN=http://localhost:4200
API_PREFIX=/api
JWT_SECRET=your-super-secret-jwt-key
LOG_LEVEL=info
EOF

# Install dependencies
status "Installing backend dependencies"
npm install

# Start backend
if [ "$MONGO_CONNECTION_SUCCESS" = "true" ]; then
    status "MongoDB connection verified, starting backend..."
    nohup npm start > /var/log/backend.log 2>&1 &
    sleep 10
    if curl -f -s "http://localhost:3000/api/health" >/dev/null 2>&1; then
        status "✅ Backend is running successfully"
    fi
else
    status "⚠️ Starting backend despite MongoDB issues..."
    nohup npm start > /var/log/backend.log 2>&1 &
fi

#################################
# FRONTEND
#################################
status "Setting up frontend"
cd $APP_DIR/frontend

# Create .env file with backend API URL
status "Creating frontend .env file"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
API_URL="http://$PUBLIC_IP/api"
status "Setting API_URL to: $API_URL"

cat > .env <<EOF
# Backend API URL - update this to match your backend server
API_URL=$API_URL
EOF

# Install dependencies
npm install

# Run the setenv.js script to configure environment
status "Running setenv.js script to configure environment"
if [ -f "scripts/setenv.js" ]; then
    node scripts/setenv.js
    status "✅ Environment configuration completed with scripts/setenv.js"
else
    status "⚠️ setenv.js script not found in scripts/ directory"
    ls -la scripts/ || status "scripts/ directory does not exist"
fi

# Start Angular development server
status "Starting Angular development server"
nohup ng serve --host 0.0.0.0 --port 4200 --disable-host-check > /var/log/angular.log 2>&1 &

status "Angular dev server started on port 4200"

#################################
# NGINX PROXY
#################################
status "Configuring Nginx proxy"

cat > /etc/nginx/sites-available/app <<EOF
server {
  listen 80 default_server;
  server_name _;

  location / {
    proxy_pass http://localhost:4200;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
  }

  location /api/ {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }

  location /status/ {
    alias /var/www/html/status/;
    autoindex on;
  }
}
EOF

ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
nginx -t && systemctl reload nginx

#################################
# FINALIZE
#################################
cp $LOG $STATUS_DIR/user-data.log 2>/dev/null || echo "Log copy failed"
cp /var/log/angular.log $STATUS_DIR/angular.log 2>/dev/null || echo "Angular not ready"
cp /var/log/backend.log $STATUS_DIR/backend.log 2>/dev/null || echo "Backend not ready"

status "Bootstrap completed"
echo "=============================="
echo "User-data finished $(date)"
echo "=============================="
