#!/bin/bash
set -eo pipefail

scriptPath="$(readlink -f "${BASH_SOURCE[0]}")"
scriptDir="$(cd "$(dirname "$scriptPath")" && pwd)"

while getopts "n:s" OPTION; do
    case $OPTION in
    n)
      appName=$OPTARG
      ;;
    s)
      skip=1
      ;;
    esac
done

if [ -v $appName ]; then
  echo "Please provide the app name by passing it with the -n parameter."
  exit 1
fi

mkdir $appName
cd $appName

echo "name: $appName" >> .lando.yml
echo "recipe: drupal11" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  php: 8.4" >> .lando.yml
echo "  xdebug: true" >> .lando.yml
echo "services:" >> .lando.yml
echo "  appserver:" >> .lando.yml
echo "    overrides:" >> .lando.yml
echo "      environment:" >> .lando.yml
echo "        PHP_IDE_CONFIG: 'serverName=appserver'" >> .lando.yml
echo "    config:" >> .lando.yml
echo "      php: php.ini" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  drush:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: /app/vendor/bin/drush --root=/app/web --uri=https://$appName.lndo.site --xdebug" >> .lando.yml

echo "memory_limit = 128M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini
echo "apc.shm_size = 64M" >> php.ini

lando start

if [[ $skip ]]; then
   echo "Skipping site installation."
   exit 0
fi

lando composer create-project drupal/recommended-project:^11 drupal11 --no-interaction
mv drupal11/{.[!.],}* .
rm -rf drupal11

if [ -f .env.example ]; then
  cp .env.example .env
elif [ ! -f .env ]; then
  touch .env
fi

mkdir -p config/sync

lando composer require drush/drush --no-interaction
lando composer require cweagans/composer-patches --no-interaction

lando rebuild -y

lando drush site-install --account-pass=admin --db-url=mysql://drupal11:drupal11@database/drupal11 --site-name=$appName --yes

chmod u+w web/sites/default web/sites/default/settings.php
configSyncSetting="\$settings['config_sync_directory'] = '../config/sync';"
if grep -q "config_sync_directory" web/sites/default/settings.php; then
  sed -i "/config_sync_directory/c\\$configSyncSetting" web/sites/default/settings.php
else
  echo "$configSyncSetting" >> web/sites/default/settings.php
fi
chmod 444 web/sites/default/settings.php

chmod 755 web/sites/default

lando composer require drupal/coffee drupal/admin_toolbar --no-interaction
lando composer require drupal/devel drupal/module_filter drupal/fpa --dev --no-interaction
lando drush pm-enable coffee admin_toolbar admin_toolbar_tools devel devel_generate module_filter fpa --yes

lando db-export initial.sql

lando drush cex --yes --quiet
lando drush status --field=bootstrap | grep -q "Successful"
test -f config/sync/core.extension.yml
cp "$scriptDir/templates/drupal.gitignore" .gitignore
git init --quiet
git add --force .gitignore
git add --all
git commit --quiet -m "Initial commit"

echo "Drupal 11 is installed and available at: https://$appName.lndo.site"
