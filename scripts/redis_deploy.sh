#!/bin/bash

set -x

# sudo yum install epel-release
#
# sudo yum install redis -y
#
# sudo systemctl start redis.service
#
# sudo systemctl enable redis
#
# sudo systemctl status redis.service
#
# redis-cli ping

# get system libraries
sudo yum install -y gcc wget

# get stable version and untar it
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable

# build dependencies too!
cd deps
sudo make hiredis jemalloc linenoise lua geohash-int
cd ..

# compile it
sudo make install

# make it globally accesible
# sudo cp src/redis-cli /usr/bin/
# redis_server_binary=`which redis-server`
# which: no redis-server in (/sbin:/bin:/usr/sbin:/usr/bin)
# echo $redis_server_binary

sudo sed -i 's/^\/etc\/init.d\/redis_$REDIS_PORT start/# \/etc\/init.d\/redis_$REDIS_PORT start/g' ./utils/install_server.sh

sudo REDIS_PORT=6379 \
REDIS_CONFIG_FILE=/etc/redis.conf \
REDIS_LOG_FILE=/var/log/redis/redis.log \
REDIS_DATA_DIR=/var/lib/redis \
REDIS_EXECUTABLE=/usr/local/bin/redis-server ./utils/install_server.sh


# master - slave comm does not work, if I create and use zone: redis. Hence changing to public
# sudo firewall-cmd --permanent --new-zone=redis

#sudo firewall-cmd --permanent --zone=public --add-port=6379/tcp

#sudo firewall-cmd --permanent --zone=public --add-port=16379/tcp
# sudo firewall-cmd --permanent --zone=redis --add-source=<client_server_private_IP>

sudo firewall-offline-cmd  --zone=public --add-port=6379/tcp

sudo firewall-offline-cmd  --zone=public --add-port=16379/tcp

/bin/systemctl restart firewalld

#sudo firewall-cmd --reload

priv_ip=`hostname -i`

sudo cp /etc/redis.conf /etc/redis.conf.backup

sudo sed -i "s/^bind 127.0.0.1/bind $priv_ip/g" /etc/redis.conf

# sudo systemctl restart redis.service

# redis-cli -h $priv_ip ping

sudo sed -i "s/^# cluster-enabled yes/cluster-enabled yes/g" /etc/redis.conf

# Don't include the file name, since it can have port # which can be different from default port.
sudo sed -i "s/^# cluster-config-file /cluster-config-file /g" /etc/redis.conf

sudo sed -i "s/^# cluster-node-timeout 15000/cluster-node-timeout 15000/g" /etc/redis.conf

sudo sed -i "s/^appendonly no/appendonly yes/g" /etc/redis.conf

sudo systemctl restart redis_6379
# sleep 10s
# sudo systemctl start redis_6379
# sleep 10s
# sudo systemctl enable redis_6379

sudo systemctl status redis_6379

/usr/local/bin/redis-cli -h $priv_ip ping

if [ $? -eq 0 ]; then
    touch /home/opc/complete;
fi
# redis-cli --cluster create 10.0.3.3:6379 10.0.3.4:6379 10.0.4.4:6379 10.0.4.3:6379 10.0.3.2:6379 10.0.4.2:6379 --cluster-replicas 1

set +x
