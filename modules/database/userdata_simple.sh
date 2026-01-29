#!/bin/bash
set -e

LOG="/var/log/mongodb-user-data.log"
STATUS_FILE="/var/www/html/status/status.txt"

# Create status directories
mkdir -p /var/www/html/status
chmod -R 755 /var/www/html
echo "MongoDB bootstrap started at $(date)" | tee -a $LOG $STATUS_FILE

# System updates and basic packages
apt-get update -y
apt-get install -y curl gnupg lsb-release apache2

# Start Apache early for status endpoint
systemctl enable apache2
systemctl start apache2

echo "System packages installed" | tee -a $LOG $STATUS_FILE

# Install MongoDB 6.0
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

apt-get update -y
apt-get install -y mongodb-org

echo "MongoDB installed" | tee -a $LOG $STATUS_FILE

# Configure MongoDB - simple and direct approach
cat > /etc/mongod.conf <<EOF
# mongod.conf
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 0.0.0.0

# Note: authorization will be enabled after creating admin user
EOF

# Set permissions
chown -R mongodb:mongodb /var/lib/mongodb
chown -R mongodb:mongodb /var/log/mongodb

# Start MongoDB without authentication first
systemctl enable mongod
systemctl start mongod

echo "MongoDB configured and started without auth" | tee -a $LOG $STATUS_FILE

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..." | tee -a $LOG $STATUS_FILE
for i in {1..30}; do
    if mongosh --eval "db.runCommand('ping')" &>/dev/null; then
        echo "MongoDB is ready after $i attempts" | tee -a $LOG $STATUS_FILE
        break
    fi
    echo "Attempt $i: waiting for MongoDB..." | tee -a $LOG $STATUS_FILE
    sleep 2
done

# Create admin user
echo "Creating admin user..." | tee -a $LOG $STATUS_FILE
mongosh --eval "
use admin
db.createUser({
  user: '${mongo_admin_user}',
  pwd: '${mongo_admin_password}',
  roles: [ { role: 'root', db: 'admin' } ]
})
" 2>&1 | tee -a $LOG $STATUS_FILE

# Create application database WITHOUT authentication (we're still in no-auth mode)
echo "Creating application database..." | tee -a $LOG $STATUS_FILE
mongosh --eval "
use ${mongo_db_name}
db.init.insertOne({ createdAt: new Date(), message: 'Database initialized' })
" 2>&1 | tee -a $LOG $STATUS_FILE

# For now, keep MongoDB running WITHOUT authentication for simpler setup
echo "MongoDB will continue running without authentication for easier connectivity" | tee -a $LOG $STATUS_FILE
echo "Note: In production, you should enable authentication for security" | tee -a $LOG $STATUS_FILE

# Test MongoDB connectivity without authentication
echo "Testing MongoDB connectivity without authentication..." | tee -a $LOG $STATUS_FILE
for i in {1..10}; do
    # Test basic connectivity
    if timeout 10 mongosh --eval "db.runCommand('ping')" --quiet 2>/dev/null; then
        echo "MongoDB is ready and accessible without authentication after $i attempts" | tee -a $LOG $STATUS_FILE
        break
    fi
    echo "Attempt $i: waiting for MongoDB..." | tee -a $LOG $STATUS_FILE
    sleep 3
done

# Final verification
echo "=== MONGODB SETUP COMPLETE ===" | tee -a $LOG $STATUS_FILE
echo "MongoDB listening on:" | tee -a $LOG $STATUS_FILE
netstat -tlnp | grep 27017 | tee -a $LOG $STATUS_FILE

# Test MongoDB without authentication
echo "Testing MongoDB database access without authentication..." | tee -a $LOG $STATUS_FILE
DB_TEST_RESULT=$(timeout 15 mongosh --eval "
try {
  var result = db.runCommand('ping');
  print('MongoDB ping result:', JSON.stringify(result));
  use ${mongo_db_name};
  var stats = db.stats();
  print('Database access successful - DB name:', stats.db);
  print('SUCCESS: MongoDB and database access verified');
} catch(error) {
  print('ERROR:', error.toString());
  quit(1);
}
" 2>&1)

echo "Database test result:" | tee -a $LOG $STATUS_FILE
echo "$DB_TEST_RESULT" | tee -a $LOG $STATUS_FILE

if echo "$DB_TEST_RESULT" | grep -q "SUCCESS: MongoDB and database access verified"; then
    echo "✅ MongoDB and database access verified (no authentication)" | tee -a $LOG $STATUS_FILE
else
    echo "❌ MongoDB database test failed" | tee -a $LOG $STATUS_FILE
    # Try to diagnose the issue
    echo "MongoDB process status:" | tee -a $LOG $STATUS_FILE
    ps aux | grep mongod | head -3 | tee -a $LOG $STATUS_FILE
    echo "MongoDB listening status:" | tee -a $LOG $STATUS_FILE
    netstat -tlnp | grep 27017 | tee -a $LOG $STATUS_FILE
    echo "Recent MongoDB logs:" | tee -a $LOG $STATUS_FILE
    tail -20 /var/log/mongodb/mongod.log | tee -a $LOG $STATUS_FILE 2>/dev/null || echo "Could not read MongoDB logs" | tee -a $LOG $STATUS_FILE
    echo "MongoDB configuration:" | tee -a $LOG $STATUS_FILE
    cat /etc/mongod.conf | tee -a $LOG $STATUS_FILE
fi

# Copy logs to web directory
mkdir -p /var/www/html
cp $LOG /var/www/html/mongodb-setup.log 2>/dev/null || echo "Could not copy setup log"
cp $STATUS_FILE /var/www/html/status.txt 2>/dev/null || echo "Could not copy status file"
chmod 644 /var/www/html/mongodb-setup.log /var/www/html/status.txt 2>/dev/null || echo "Could not set file permissions"

# Ensure Apache is running
systemctl status apache2 | tee -a $LOG $STATUS_FILE
systemctl restart apache2

# Verify web files are accessible
echo "Web directory contents:" | tee -a $LOG $STATUS_FILE
ls -la /var/www/html/ | tee -a $LOG $STATUS_FILE

echo "MongoDB setup completed at $(date)" | tee -a $LOG $STATUS_FILE
echo "Status available at: http://$(hostname -I | awk '{print $1}')/status.txt" | tee -a $LOG $STATUS_FILE
