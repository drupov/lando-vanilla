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
echo "recipe: drupal8" >> .lando.yml
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
echo "    cmd: drush --root=/app/web" >> .lando.yml
echo "  drupal:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: drupal --root=/app/web" >> .lando.yml

echo "memory_limit = 128M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini

lando start

if [[ $skip ]]; then
   echo "Skipping site installation."
   exit 0
fi

lando composer create-project drupal-composer/drupal-project:8.x-dev drupal8 --stability dev --no-interaction
mv drupal8/{.[!.],}* .
rm -rf drupal8

lando restart

lando drush site-install --account-pass=admin --db-url=mysql://drupal8:drupal8@database/drupal8 --site-name=$appName --yes

chmod 755 web/sites/default

lando composer require drupal/coffee drupal/admin_toolbar
lando composer require drupal/devel drupal/module_filter drupal/fpa --dev
lando drush pm-enable coffee admin_toolbar_tools devel devel_generate webprofiler module_filter fpa --yes

lando db-export initial.sql

echo "Browse your site by visiting:"
lando info | grep lndo.site
