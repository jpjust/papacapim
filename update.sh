#!/bin/sh
DIR=$(pwd)
sudo chown -R just: $DIR
git pull
git reset --hard
/opt/rbenv/shims/bundle install
RAILS_ENV=production /opt/rbenv/shims/bundle exec rake db:migrate
sudo chown -R www-data: $DIR
sudo touch tmp/restart.txt
