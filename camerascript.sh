# Enable camera, instead of using raspi-config.
echo "start_x=1" | sudo tee --append /boot/config.txt
echo "gpu_mem=128" | sudo tee --append /boot/config.txt
echo "disable_camera_led=1" | sudo tee --append /boot/config.txt

# Download RPi Cam Web Interface.
git clone https://github.com/silvanmelchior/RPi_Cam_Web_Interface.git
cd RPi_Cam_Web_Interface
chmod u+x *.sh

# Make sure the camera is accessible by the IP address. Default the camera is accessible via the 'html' subfolder. 
sed -i -e 's/rpicamdir=\\"html\\"/rpicamdir=\\"\\"/g' /home/pi/RPi_Cam_Web_Interface/install.sh

# Install RPi Cam Web Interface.
./install.sh q

# Remove the text that's displayed over the image.
sudo sed -i -e 's/annotation .*/annotation/g' /etc/raspimjpeg

# Optional change rotation of the camera, in case the image is upside down.
# sudo sed -i -e 's/rotation .*/rotation 0/g' /etc/raspimjpeg


