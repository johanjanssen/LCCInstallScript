sudo apt-get install -y lirc
echo "lirc_dev" | sudo tee --append /etc/modules

# If you want to use other GPIO pins for the infrared transmitter than you have to change the values below.
echo "lirc_rpi gpio_in_pin=18 gpio_out_pin=17" | sudo tee --append /etc/modules

sudo cp hardware.conf /etc/lirc/hardware.conf
echo "dtoverlay=lirc-rpi,gpio_in_pin=18,gpio_out_pin=17" | sudo tee --append /boot/config.txt
sudo modprobe lirc_rpi softcarrier=0
sudo /etc/init.d/lirc stop
sudo /etc/init.d/lirc start

# Compile the C application that sends the infrared signals.
gcc -lpthread /home/pi/LCCInstallScript/control.c -o /home/pi/LCCInstallScript/infrared

