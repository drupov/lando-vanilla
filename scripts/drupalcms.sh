#!/bin/bash

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
echo "    cmd: drush --root=/app/web --uri=https://$appName.lndo.site" >> .lando.yml

echo "memory_limit = 256M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini
echo "apc.shm_size = 64M" >> php.ini

lando start

if [[ $skip ]]; then
   echo "Skipping site installation."
   exit 0
fi

lando composer create-project drupal/cms --no-interaction
mv cms/{.[!.],}* .
rm -rf cms

lando drush site-install --account-pass=admin --db-url=mysql://drupal11:drupal11@database/drupal11 --site-name=$appName --yes

chmod 755 web/sites/default

# Installation with Drush fails if the memory_limit is too low
sed -i 's/memory_limit = 256M/memory_limit = 128M/' php.ini

lando restart

lando composer require drupal/coffee --no-interaction
lando composer require drupal/devel drupal/module_filter drupal/fpa --dev --no-interaction
lando drush pm-enable coffee devel devel_generate module_filter fpa --yes

echo "Drupal CMS is installed and available at: https://$appName.lndo.site"
