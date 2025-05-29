wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip -P /tmp
unzip -d /tmp /tmp/gradle-6.9.4-bin.zip
/tmp/gradle-6.9.4/bin/gradle wrapper --gradle-version 6.9.4
chmod +x gradlew
