sudo apt-get update -y

# Remove or comment one of the lines below to disable the specific functionality.
sh /home/pi/LCCInstallScript/infraredscript.sh
sh /home/pi/LCCInstallScript/camerascript.sh
sh /home/pi/LCCInstallScript/springbootscript.sh

sudo reboot
