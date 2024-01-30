#!/usr/bin/env bash
#   about: Azure Metrics Server powered by Prometheus - Uninstaller
#          script to uninstall the python program as a linux service
#  author: Peter Karacsonyi <peter.karacsonyi85@domain.com>
#    date: 11 Apr 2023
# license: GNU General Public License, version 2
#####

# use colors for easy log reading
N='\033[0m'
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
P='\033[0;35m'

INSTALL_DIR='/opt/azmetrics' # be careful as this script removes the directory with rm -rf

echo -e "${B}TASK [removing files from install dir] ***************************************${N}"
sudo rm -rf $INSTALL_DIR && echo -e "${G}REMOVE DIR $INSTALL_DIR: OK${N}"
echo -e "${B}TASK [uninstalling service] **************************************************${N}"
sudo systemctl stop azmetrics.service &>/dev/null || { echo -e "${G}SERVICE NOT FOUND.${N}" ; exit 1; } && echo -e "${G}STOPPING SERVICE: OK${N}"
sudo systemctl disable azmetrics.service &>/dev/null && echo -e "${G}DISBALING SERVICE: OK${N}"
sudo rm /etc/systemd/system/azmetrics.service &>/dev/null && echo -e "${G}REMOVING SERVICE /etc/systemd/system/azmetrics.service: OK${N}"
echo -e "${B}TASK [reloading systemctl daemon] ********************************************${N}"
sudo systemctl daemon-reload &>/dev/null && echo -e "${G}RELOADING SYSTEMCTL DAEMON: OK${N}"
echo -e "${Y}Warning: make sure the .azure_creds file remains protected'${N}"

