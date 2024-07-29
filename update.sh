#!/bin/sh
sudo chown -R just: *
git pull
git reset --hard
bundle install
RAILS_ENV=production bundle exec rake db:migrate
sudo chown -R www-data: *
sudo touch tmp/restart.txt
