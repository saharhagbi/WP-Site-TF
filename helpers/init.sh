#!/bin/bash

echo "DB_NAME = ${db-name}" >> /home/ec2-user/hello.txt
echo "DB_ENDPOINT = ${db-endpoint}" >> /home/ec2-user/hello.txt
echo "DB_USERNAME = ${db-username}" >> /home/ec2-user/hello.txt
echo "DB_PASSWORD = ${db-password}" >> /home/ec2-user/hello.txt

# install apache
sudo yum install -y httpd
sudo service httpd start

# download word press
cd /home/ec2-user
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# config wp-config.php
cd wordpress
cp wp-config-sample.php wp-config.php

sed -i 's/database_name_here/${db-name}/g' wp-config.php
sed -i 's/localhost/${db-endpoint}/g' wp-config.php
sed -i 's/username_here/${db-username}/g' wp-config.php
sed -i 's/password_here/${db-password}/g' wp-config.php

# add aws credentials
cat <<EOT >> credfile.txt
define( 'AS3CF_SETTINGS', serialize( array (

    'provider' => 'aws',

    'access-key-id' => '${access-key}',

    'secret-access-key' => '${secret-key}',

) ) );
EOT

sed -i -e "/define( 'WP_DEBUG', false );/ r credfile.txt" wp-config.php

# deploying wordpress
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cd /home/ec2-user
sudo cp -r wordpress/* /var/www/html/
sudo service httpd restart

                     