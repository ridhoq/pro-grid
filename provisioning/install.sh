#!/usr/bin/env bash

# works on ubuntu 14.04

set -e           
set -o pipefail   

build_dir=$1
cache_dir=$2
env_dir=$3

apt-get update
# get git and redis
apt-get -y install git redis-server

# install node
(
  cd /tmp

  git clone https://github.com/heroku/heroku-buildpack-nodejs.git

  ./heroku-buildpack-nodejs/bin/compile $build_dir $cache_dir
)

# install node environment variables
NODE_PATH=${build_dir}'/vendor/node/bin'
echo 'export PATH=$PATH:'${NODE_PATH} >> /etc/profile

# globally install nodemon
${NODE_PATH}/npm install -g nodemon forever 2>&1

# install nodemon files
cp ${build_dir}/provisioning/nodemon.json /home/${SUDO_USER}

# make redis and progrid start on boot
cp ${build_dir}/provisioning/redis-server.conf /etc/init
update-rc.d redis-server disable
initctl start redis-server

# pro-grid run on boot
cp ${build_dir}/provisioning/pro-grid.conf /etc/init
#initctl start pro-grid

printenv
