#!/bin/bash
# MongoDB installation and configuration script for Ubuntu

# Update system
apt-get update -y

# Install gnupg and curl
apt-get install -y gnupg curl

# Add MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-${mongodb_version}.asc | gpg -o /usr/share/keyrings/mongodb-server-${mongodb_version}.gpg --dearmor

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${mongodb_version}.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${mongodb_version} multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${mongodb_version}.list

# Update package database
apt-get update -y

# Install MongoDB
apt-get install -y mongodb-org

# Create MongoDB data directory
mkdir -p /data/db
chown mongodb:mongodb /data/db

# Configure MongoDB to accept connections from VPC
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

# Enable and start MongoDB
systemctl enable mongod
systemctl start mongod

# Create a log entry
echo "MongoDB installation completed at $(date)" >> /var/log/mongodb-setup.log
