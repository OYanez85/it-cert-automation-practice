#!/bin/bash
# setup_puppet.sh
#
# This script sets up the Puppet Agent on the VM.
# It configures the Puppet Agent to connect to a Puppet Master,
# and ensures that the Puppet service starts automatically on boot.
#
# This script is based on lab instructions for customizing VMs in GCP,
# where after deploying a web application as a systemd service,
# we prepare the VM for scaling by integrating configuration management (Puppet).
#
# Update the PUPPET_MASTER variable below with your Puppet Master's hostname.

set -e

# Set your Puppet Master server hostname here.
PUPPET_MASTER="puppetmaster.example.com"

echo "Starting Puppet Agent setup..."

# Verify Puppet is installed.
if ! command -v /opt/puppetlabs/bin/puppet &> /dev/null; then
  echo "Error: Puppet Agent is not installed. Please install puppet-agent first."
  exit 1
fi

echo "Puppet Agent version: $(/opt/puppetlabs/bin/puppet --version)"

# Define the Puppet configuration file location.
PUPPET_CONF="/etc/puppetlabs/puppet/puppet.conf"

# Create the configuration file if it does not exist.
if [ ! -f "$PUPPET_CONF" ]; then
  echo "Puppet configuration file not found. Creating $PUPPET_CONF..."
  sudo mkdir -p /etc/puppetlabs/puppet
  sudo touch "$PUPPET_CONF"
fi

# Check if a Puppet server is already configured.
if grep -q "^server=" "$PUPPET_CONF"; then
  echo "Puppet server is already configured in puppet.conf."
else
  echo "Adding Puppet Master server setting to puppet.conf..."
  # Append the [main] section and server setting.
  sudo bash -c "echo '[main]' >> $PUPPET_CONF"
  sudo bash -c "echo 'server=$PUPPET_MASTER' >> $PUPPET_CONF"
fi

# Enable and start the Puppet service.
echo "Enabling Puppet service to start on boot..."
sudo systemctl enable puppet
echo "Restarting Puppet service..."
sudo systemctl restart puppet

echo "Puppet Agent setup is complete."
echo "Puppet Agent status:"
sudo systemctl status puppet --no-pager
