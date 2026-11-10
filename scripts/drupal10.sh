#!/bin/bash

set -eo pipefail

scriptDir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$scriptDir/_bootstrap.sh"

prepare_app_directory "n:s" "$@"

echo "name: $appName" >> .lando.yml
echo "recipe: drupal10" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  php: 8.4" >> .lando.yml
echo "  xdebug: true" >> .lando.yml
echo "services:" >> .lando.yml
echo "  appserver:" >> .lando.yml
echo "    config:" >> .lando.yml
echo "      php: php.ini" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  drush:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: drush --root=/app/web --uri=https://$appName.lndo.site" >> .lando.yml
echo "env_file:" >> .lando.yml
echo "  - .env" >> .lando.yml

echo "memory_limit = 128M" >> php.ini
echo "xdebug.start_with_request = 1" >> php.ini
echo "xdebug.log_level = 0" >> php.ini
echo "apc.shm_size = 64M" >> php.ini

mkdir -p .vscode
cp "$scriptDir/templates/launch.json" .vscode/launch.json

lando start

if [[ ${skip:-} ]]; then
   echo "Skipping site installation."
   exit 0
fi

lando composer create-project drupal/recommended-project:^10 drupal10 --no-interaction --no-install
cd drupal10
lando composer remove drupal/core-project-message --no-interaction
lando composer config --unset extra.drupal-core-project-message --no-interaction
lando composer config --unset homepage --no-interaction
lando composer config --unset support --no-interaction
lando composer require drush/drush --no-interaction
lando composer config allow-plugins.tbachert/spi true --no-interaction
lando composer require drupal/core-dev --dev --with-all-dependencies --no-interaction
lando composer config allow-plugins.cweagans/composer-patches true --no-interaction
lando composer require cweagans/composer-patches:~2.0 --no-interaction
cd ..
mv drupal10/{.[!.],}* .
rm -rf drupal10

cp "$scriptDir/templates/.gitignore" .gitignore

create_agents_file "Drupal 10"

lando rebuild -y

mkdir -p config/sync web/sites/default/files
cp web/sites/default/default.settings.php web/sites/default/settings.php
echo "\$settings['config_sync_directory'] = '../config/sync';" >> web/sites/default/settings.php
lando drush site-install --account-pass=admin --db-url=mysql://drupal10:drupal10@database/drupal10 --site-name=$appName --yes

lando composer require drupal/coffee drupal/admin_toolbar --no-interaction
lando composer require drupal/devel drupal/module_filter drupal/fpa --dev --no-interaction
lando drush pm-enable coffee admin_toolbar admin_toolbar_tools devel devel_generate module_filter fpa --yes

lando db-export initial.sql

lando drush cex --yes
git init
git add .
git commit -m "Initial commit"

echo "Drupal 10 is installed and available at: https://$appName.lndo.site"
