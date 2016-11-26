sudo apt-get install -y oracle-java8-jdk
wget http://www.mirrorservice.org/sites/ftp.apache.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
sudo tar xvf apache-maven-3.3.9-bin.tar.gz  -C /opt
git clone https://github.com/johanjanssen/LCC.git
/opt/apache-maven-3.3.9/bin/mvn -f /home/pi/LCC/pom.xml clean package
sudo sed -i '/^exit/s/^exit/\/usr\/lib\/jvm\/jdk-8-oracle-arm32-vfp-hflt\/bin\/java -jar \/home\/pi\/LCC\/target\/*.jar \& \n&/' /etc/rc.local

# Command to start the application manually
# /usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt/bin/java -jar /home/pi/LCC/target/*.jar

