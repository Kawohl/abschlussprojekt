#!/bin/bash
apt-get update

sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community:/testing/Ubuntu_16.04/ /' > /etc/apt/sources.list.d/owncloud-client.list"
sudo apt-get update
apt-get --allow-unauthenticated install -y owncloud-client
. /etc/os-release 

(owncloudcmd --version | grep -q "ownCloud version" && echo "SUCCESS: version $(owncloudcmd --version | head -1) installed! System: $PRETTY_NAME" || echo "FAIL: ownCloud not installed\! ") >> /logs/desktop.install.log 2>&1
