#!/bin/bash

noAppNameMessage="Please provide the app name by passing it with the -n parameter."

while getopts "n:" OPTION; do
  case $OPTION in
  n)
    appName=$OPTARG
    ;;
  *)
    echo $noAppNameMessage
    exit 1
  esac
done

if [ -v $appName ]; then
  echo $noAppNameMessage
  exit 1
fi

mkdir $appName
cd $appName

echo "name: $appName" >> .lando.yml
echo "recipe: drupal7" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  xdebug: true" >> .lando.yml
echo "services:" >> .lando.yml
echo "  appserver:" >> .lando.yml
echo "    overrides:" >> .lando.yml
echo "      environment:" >> .lando.yml
echo "        PHP_IDE_CONFIG: 'serverName=$appName.lndo.site'" >> .lando.yml
echo "    config:" >> .lando.yml
echo "      php: php.ini" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  drush:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: drush --root=/app/web --uri=https://$appName.lndo.site" >> .lando.yml

echo "memory_limit = 128M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini

lando start

lando drush pm-download drupal-7 --drupal-project-rename=web

lando restart

lando drush site-install --account-pass=admin --db-url=mysql://drupal7:drupal7@database/drupal7 --site-name=$appName --yes

lando drush pm-disable toolbar overlay --yes
lando drush pm-uninstall toolbar overlay --yes

lando drush pm-download ctools coffee entity entityreference devel views admin_menu token module_filter search_krumo features strongarm diff fpa --yes

lando drush pm-enable coffee page_manager entityreference devel devel_generate views_ui admin_menu_toolbar token module_filter search_krumo features strongarm diff fpa --yes

lando db-export initial.sql

git init
git add .
git commit -m "Initial commit"

echo "Drupal 7 is installed and available at: https://$appName.lndo.site"
