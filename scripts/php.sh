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

# echo "name: $appName" >> .lando.yml
# echo "recipe: lamp" >> .lando.yml
# echo "config:" >> .lando.yml
# echo "  webroot: ." >> .lando.yml
# echo "  xdebug: true" >> .lando.yml
# echo "  php: 8.1" >> .lando.yml
# echo "services:" >> .lando.yml
# echo "  appserver:" >> .lando.yml
# echo "    overrides:" >> .lando.yml
# echo "      environment:" >> .lando.yml
# echo "        PHP_IDE_CONFIG: 'serverName=appserver'" >> .lando.yml
# echo "    config:" >> .lando.yml
# echo "      php: php.ini" >> .lando.yml

echo "memory_limit = 128M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini

echo "<?php" >> index.php
echo "" >> index.php
echo "print 'Hello world';" >> index.php

lando start

echo "PHP playground is installed and available at: https://$appName.lndo.site"
