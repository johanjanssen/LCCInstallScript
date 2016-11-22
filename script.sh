sudo apt-get update
sudo apt-get install -y lirc oracle-java8-jdk
echo "lirc_dev" | sudo tee --append /etc/modules
echo "lirc_rpi gpio_in_pin=18 gpio_out_pin=17" | sudo tee --append /etc/modules
sudo cp hardware.conf /etc/lirc/hardware.conf
echo "dtoverlay=lirc-rpi,gpio_in_pin=18,gpio_out_pin=17" | sudo tee --append /boot/config.txt
sudo modprobe lirc_rpi softcarrier=0
sudo /etc/init.d/lirc stop
sudo /etc/init.d/lirc start
wget http://www.mirrorservice.org/sites/ftp.apache.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
sudo tar xvf apache-maven-3.3.9-bin.tar.gz  -C /opt
export PATH=/opt/apache-maven-3.3.9/bin:$PATH
mvn -f ../LCC/pom.xml clean package
sudo sed -i '/^exit/s/^exit/\/usr\/lib\/jvm\/jdk-8-oracle-arm32-vfp-hflt\/bin\/java -jar \/home\/pi\/LCC\/target\/*.jar \& \n&/' /etc/rc.local
gcc -lpthread control.c -o /home/pi/LCC/infrared
/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt/bin/java -jar /home/pi/LCC/target/*.jar

