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
echo "recipe: drupal9" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  php: 7.3" >> .lando.yml
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

echo "memory_limit = 512M" >> php.ini

lando start

if [[ $skip ]]; then
   echo "Skipping site installation."
   exit 0
fi

lando composer create-project drupal-composer/drupal-project:9.x-dev drupal9 --no-interaction
mv drupal9/{.[!.],}* .
rm -rf drupal9

lando restart

lando drush site-install --account-pass=admin --db-url=mysql://drupal9:drupal9@database/drupal9 --site-name=$appName --yes

chmod 755 web/sites/default

echo "Browse your site by visiting:"
lando info | grep lndo.site
