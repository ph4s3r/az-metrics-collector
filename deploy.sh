#!/usr/bin/env bash
#   about: Azure Metrics Server powered by Prometheus - Installer
#          script to install the python program as a linux service
#  author: Peter Karacsonyi <peter.karacsonyi@domain.com>
#    date: 11 Apr 2023
# license: GNU General Public License, version 2
#####

############################## begin config
# python path
PYTHON='/usr/bin/python3'
# install dir
INSTALL_DIR='/opt/azmetrics'
# run as 
RUNAS='<yourUserName>'
# prometheus server port
PROMETHEUS_HTTP_PORT='8000'
# data refresh interval (cron format)
REFRESH_CRON='0 * * * *'
# subscription filter
SUB_FILTER_KEYWORD='landingzone'
############################## end config



############################## begin constants
# use colors for easy log reading
N='\033[0m'
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
P='\033[0;35m'
# disable writing bytecode
export PYTHONDONTWRITEBYTECODE=1
# pass variables to the app
export PROMETHEUS_HTTP_PORT=$PROMETHEUS_HTTP_PORT
export REFRESH_CRON=$REFRESH_CRON
export SUB_FILTER_KEYWORD=$SUB_FILTER_KEYWORD
############################## end constants


# check user and creds file
echo -e "${B}TASK [checking if target user exists]*****************************************${N}"
if id "$RUNAS" &>/dev/null; then
    echo -e "${G}USER $RUNAS: OK${N}"
else
    echo -e "${R}USER $RUNAS: MISSING, EXITING SCRIPT.${N}"
    exit 1
fi
echo -e "${B}TASK [checking for azure creds file]******************************************${N}"
AZURE_CREDS_FILE=$(eval echo "~$RUNAS")/.azure_creds
stat $AZURE_CREDS_FILE >/dev/null || { echo -e "${R}AZURE CREDENTIALS FILE $AZURE_CREDS_FILE: MISSING, EXITING SCRIPT.${N}"  ; exit 1; } && echo -e "${G}AZURE CREDENTIALS FILE $AZURE_CREDS_FILE EXISTS: OK${N}"
sudo chmod 600 $AZURE_CREDS_FILE || { echo -e "${R}$AZURE_CREDS_FILE MUST BE PROTECTED (600), EXITING SCRIPT.${N}"  ; exit 1; } && echo -e "${G}CHMOD 700 $AZURE_CREDS_FILE: OK${N}"

# running uninstaller first then copy files to the install/working dir
echo -e "${P}TASK [clean install]**********************************************************${N}"
./uninstall_service.sh
sudo mkdir -p $INSTALL_DIR
sudo cp -rf ./* $INSTALL_DIR

echo -e "${Y}INFO [logging]****************************************************************${N}"
echo -e "${Y}Logs can be viewed with 'journalctl -u azmetrics.service'${N}"

echo -e "${B}TASK [checking python version] ***********************************************${N}"
# minimum requirement is 3.7 by the azure SDK libs used at the time of writing the script
PYVERSION=$(sudo $PYTHON --version |  awk '{print $2}' | awk -F'.' '{ print $1"."$2 }')
if (( $(echo "$PYVERSION <= 3.7" | bc -l) )); then
    echo -e "${R}PYTHON VERSION $PYVERSION LOWER THAN 3.7, EXITING SCRIPT.${N}" 
    exit 1
else
    echo -e "${G}PYTHON VERSION $PYVERSION: OK${N}"
fi

echo -e "${B}TASK [Installing python requirements] ****************************************${N}"
sudo $PYTHON -m pip install -q --upgrade -r $INSTALL_DIR/requirements.txt || echo -e "${Y}ERROR INSTALLING REQUIRED PYTHON PACKAGES${N}" && echo -e "${G}PYTHON PACKAGES:OK${N}"

echo -e "${B}TASK [setting up the script as service] **************************************${N}"
sudo sed -i "s/0000/$RUNAS/g" $INSTALL_DIR/azmetrics.service
sudo sed -i "s/<hostname>:<port>/<$HOSTNAME>:<$PROMETHEUS_HTTP_PORT>/g" $INSTALL_DIR/prometheus.yml
sudo cp $INSTALL_DIR/azmetrics.service /etc/systemd/system/azmetrics.service || { echo -e "${R}FAILED TO COPY SERVICE FILE TO /etc/systemd/system/, EXITING SCRIPT${N}" ; exit 1; } && echo -e "${G}DEPLOYING SERVICE TO /etc/systemd/system/azmetrics.service: OK${N}"
sudo chmod 664 /etc/systemd/system/azmetrics.service
sudo systemctl daemon-reload &>/dev/null || { echo -e "${R}SYSTEMCTL DAEMON-RELOAD FAILED, EXITING SCRIPT${N}" ; exit 1; }
sudo systemctl enable azmetrics.service &>/dev/null && echo -e "${G}ENABLING SERVICE: OK${N}"

echo -e "${B}TASK [starting service] ******************************************************${N}"
sudo systemctl start azmetrics.service || { echo -e "${R}FAILED TO START SERVICE, EXITING SCRIPT${N}" ; exit 1; } && echo -e "${G}STARTING SERVICE: OK${N}"

echo -e "${B}TASK [checking service status] ***********************************************${N}"
sleep 10
sudo systemctl status azmetrics.service
sudo systemctl is-active --quiet azmetrics.service || { echo -e "${R}SERVICE STOPPED, EXITING SCRIPT${N}" ; exit 1; }

echo -e "${B}TASK [waiting 25 sec then testing endpoint] ***********************************${N}"
sleep 25
wget -q -S -O - http://localhost:$PROMETHEUS_HTTP_PORT 2>&1