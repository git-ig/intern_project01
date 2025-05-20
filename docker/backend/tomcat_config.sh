cd /opt
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
tar -xzf apache-tomcat-9.0.85.tar.gz
ln -s apache-tomcat-9.0.85 tomcat
chmod +x /opt/tomcat/bin/*.sh
rm -rf /opt/tomcat/webapps/ROOT
sed -i 's/<Connector port="8080"/<Connector port="8080" maxPostSize="104857600"/' /opt/tomcat/conf/server.xml
useradd -s /bin/sh tomcat
chown -R tomcat:tomcat /opt/apache-tomcat-9.0.85
ln -s /opt/tomcat/bin/catalina.sh /usr/local/bin/catalina
cp /backend/*.war /opt/tomcat/webapps/
catalina start
