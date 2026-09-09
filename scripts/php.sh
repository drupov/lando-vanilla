#!/bin/bash

scriptDir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$scriptDir/_bootstrap.sh"

prepare_app_directory "n:s" "$@"

echo "name: $appName" >> .lando.yml
echo "services:" >> .lando.yml
echo "  appserver:" >> .lando.yml
echo "    type: php:8.5" >> .lando.yml
echo "    via: cli" >> .lando.yml
echo "    xdebug: true" >> .lando.yml
echo "    config:" >> .lando.yml
echo "      php: php.ini" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  php:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "  composer:" >> .lando.yml
echo "    service: appserver" >> .lando.yml

echo "memory_limit = 128M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini

lando start

echo "PHP is available in $appName with: lando php"
echo "Composer is available in $appName with: lando composer"
