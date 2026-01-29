#!/bin/bash
set -e

LOG="/var/log/mongodb-user-data.log"
STATUS_FILE="/var/www/html/status/status.txt"

# -------- Logging y status --------
mkdir -p /var/www/html/status
chmod -R 755 /var/www/html
echo "MongoDB bootstrap started at $(date)" | tee -a $LOG $STATUS_FILE

# -------- Update system and install dependencies --------
apt-get update -y
apt-get install -y curl gnupg lsb-release

# -------- Setup additional EBS storage for MongoDB data --------
echo "Setting up additional EBS storage..." | tee -a $LOG $STATUS_FILE

# Wait for the EBS volume to be attached
for i in {1..30}; do
    if [ -b /dev/nvme1n1 ] || [ -b /dev/xvdf ]; then
        echo "EBS volume detected" | tee -a $LOG $STATUS_FILE
        break
    fi
    echo "Waiting for EBS volume attachment, attempt $i..." | tee -a $LOG $STATUS_FILE
    sleep 2
done

# Determine the device name (AWS uses different naming conventions)
if [ -b /dev/nvme1n1 ]; then
    DEVICE="/dev/nvme1n1"
elif [ -b /dev/xvdf ]; then
    DEVICE="/dev/xvdf"
else
    echo "WARNING: EBS volume not found, using default storage" | tee -a $LOG $STATUS_FILE
    DEVICE=""
fi

if [ -n "$DEVICE" ]; then
    # Create filesystem if it doesn't exist
    if ! file -s $DEVICE | grep -q filesystem; then
        echo "Creating filesystem on $DEVICE" | tee -a $LOG $STATUS_FILE
        mkfs -t xfs $DEVICE
    fi
    
    # Create MongoDB data directory and mount the volume
    mkdir -p /data/db
    echo "$DEVICE /data/db xfs defaults,nofail 0 2" >> /etc/fstab
    mount -a
    
    # Set proper ownership for MongoDB
    chown -R mongodb:mongodb /data/db
    chmod 755 /data/db
    
    echo "EBS volume mounted successfully at /data/db" | tee -a $LOG $STATUS_FILE
else
    # Fallback to default directory
    mkdir -p /data/db
    chown -R mongodb:mongodb /data/db
    echo "Using default storage location" | tee -a $LOG $STATUS_FILE
fi

# -------- Add MongoDB repo --------
curl -fsSL https://www.mongodb.org/static/pgp/server-${mongodb_version}.asc \
  | gpg --dearmor -o /usr/share/keyrings/mongodb-server-${mongodb_version}.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${mongodb_version}.gpg ] \
https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/${mongodb_version} multiverse" \
  | tee /etc/apt/sources.list.d/mongodb-org-${mongodb_version}.list

apt-get update -y
apt-get install -y mongodb-org

# -------- Configure MongoDB --------
# Stop MongoDB service first to ensure clean configuration
systemctl stop mongod || true

# Configure MongoDB to bind to all interfaces and enable auth
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

# Update data directory path if we have custom storage
if [ -d "/data/db" ] && [ -n "$DEVICE" ]; then
    sed -i 's|dbPath: /var/lib/mongodb|dbPath: /data/db|' /etc/mongod.conf
    echo "MongoDB configured to use custom data directory: /data/db" | tee -a $LOG $STATUS_FILE
fi

# Enable security (authorization)
cat >> /etc/mongod.conf <<EOF
security:
  authorization: enabled
EOF

# Ensure MongoDB data directory has correct permissions
chown -R mongodb:mongodb /var/lib/mongodb /data/db 2>/dev/null || true
chown mongodb:mongodb /tmp/mongodb-27017.sock 2>/dev/null || true

# Enable and start MongoDB
systemctl enable mongod
systemctl start mongod

# Wait for MongoDB to be ready with more robust checking
echo "Waiting for MongoDB to start..." | tee -a $LOG $STATUS_FILE
for i in {1..30}; do
    if mongosh --eval "db.runCommand('ping')" &>/dev/null; then
        echo "MongoDB is ready after $i attempts" | tee -a $LOG $STATUS_FILE
        break
    fi
    echo "Attempt $i: MongoDB not ready yet, waiting..." | tee -a $LOG $STATUS_FILE
    sleep 2
done

# Verify MongoDB is running and listening
echo "MongoDB process status:" | tee -a $LOG $STATUS_FILE
ps aux | grep mongod | grep -v grep | tee -a $LOG $STATUS_FILE

echo "MongoDB port status:" | tee -a $LOG $STATUS_FILE
netstat -tlnp | grep 27017 | tee -a $LOG $STATUS_FILE

echo "MongoDB installed and configured with auth" | tee -a $LOG $STATUS_FILE

# -------- Create admin user --------
echo "Creating MongoDB admin user..." | tee -a $LOG $STATUS_FILE

# Wait a bit more and retry user creation with better error handling
for i in {1..5}; do
    if mongosh --eval "
use admin
db.createUser({
  user: '${mongo_admin_user}',
  pwd: '${mongo_admin_password}',
  roles: [ { role: 'root', db: 'admin' } ]
})
    " 2>&1 | tee -a $LOG; then
        echo "Admin user created successfully on attempt $i" | tee -a $LOG $STATUS_FILE
        break
    else
        echo "Failed to create admin user, attempt $i, retrying..." | tee -a $LOG $STATUS_FILE
        sleep 3
    fi
done

# -------- Create application database --------
echo "Creating application database..." | tee -a $LOG $STATUS_FILE

# Create application database with retry logic
for i in {1..5}; do
    if mongosh -u "${mongo_admin_user}" -p "${mongo_admin_password}" --authenticationDatabase admin --eval "
use ${mongo_db_name}
db.init.insertOne({ createdAt: new Date(), message: 'Database initialized', version: 1 })
    " 2>&1 | tee -a $LOG; then
        echo "Application database '${mongo_db_name}' created successfully on attempt $i" | tee -a $LOG $STATUS_FILE
        break
    else
        echo "Failed to create application database, attempt $i, retrying..." | tee -a $LOG $STATUS_FILE
        sleep 3
    fi
done

echo "MongoDB admin user and database '${mongo_db_name}' created" | tee -a $LOG $STATUS_FILE

# -------- Final verification and status --------
echo "=== MONGODB SETUP VERIFICATION ===" | tee -a $LOG $STATUS_FILE

# Verify MongoDB is listening on all interfaces
echo "MongoDB listening status:" | tee -a $LOG $STATUS_FILE
netstat -tlnp | grep 27017 | tee -a $LOG $STATUS_FILE
ss -tlnp | grep 27017 | tee -a $LOG $STATUS_FILE

# Test authentication
echo "Testing MongoDB authentication:" | tee -a $LOG $STATUS_FILE
mongosh -u "${mongo_admin_user}" -p "${mongo_admin_password}" --authenticationDatabase admin --eval "
db.runCommand('ping')
db.runCommand({connectionStatus: 1})
" 2>&1 | tee -a $LOG $STATUS_FILE

# List databases to confirm setup
echo "Available databases:" | tee -a $LOG $STATUS_FILE
mongosh -u "${mongo_admin_user}" -p "${mongo_admin_password}" --authenticationDatabase admin --eval "
show dbs
" 2>&1 | tee -a $LOG $STATUS_FILE

# Show MongoDB configuration
echo "MongoDB configuration check:" | tee -a $LOG $STATUS_FILE
echo "  - Bind IP: $(grep bindIp /etc/mongod.conf)" | tee -a $LOG $STATUS_FILE
echo "  - Port: 27017" | tee -a $LOG $STATUS_FILE
echo "  - Auth enabled: yes" | tee -a $LOG $STATUS_FILE
echo "  - Instance IP: $(hostname -I | awk '{print $1}')" | tee -a $LOG $STATUS_FILE

# Create a simple HTTP status endpoint for debugging
echo "Creating status endpoint..." | tee -a $LOG $STATUS_FILE
apt-get install -y apache2
systemctl enable apache2
systemctl start apache2

# Copy logs to web directory for remote debugging
cp $LOG /var/www/html/mongodb-setup.log
cp $STATUS_FILE /var/www/html/status.txt
chmod 644 /var/www/html/mongodb-setup.log /var/www/html/status.txt

echo "==================================" | tee -a $LOG $STATUS_FILE
echo "MongoDB bootstrap completed at $(date)" | tee -a $LOG $STATUS_FILE
echo "Status endpoint available at: http://$(hostname -I | awk '{print $1}')/status.txt" | tee -a $LOG $STATUS_FILE
echo "Setup log available at: http://$(hostname -I | awk '{print $1}')/mongodb-setup.log" | tee -a $LOG $STATUS_FILE
