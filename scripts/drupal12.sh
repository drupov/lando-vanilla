#!/bin/bash

set -eo pipefail

scriptDir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$scriptDir/_bootstrap.sh"

prepare_app_directory "n:s" "$@"

echo "name: $appName" >> .lando.yml
# TODO: Switch to Lando's Drupal 12 recipe when it is available. Until then,
# use the Drupal 11 recipe, which supports the PHP 8.5 environment Drupal 12 needs.
echo "recipe: drupal11" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  php: 8.5" >> .lando.yml
echo "  composer_version: 2.9.3" >> .lando.yml
echo "  database: mysql:8.4" >> .lando.yml
echo "  xdebug: true" >> .lando.yml
echo "services:" >> .lando.yml
echo "  appserver:" >> .lando.yml
echo "    config:" >> .lando.yml
echo "      php: php.ini" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  drush:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: drush --root=/app/web --uri=https://$appName.lndo.site --xdebug" >> .lando.yml
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

# TODO: Remove @beta when Drupal 12 has a stable release.
lando composer create-project drupal/recommended-project:^12@beta drupal12 --no-interaction --no-install
cd drupal12
lando composer remove drupal/core-project-message --no-interaction
lando composer config --unset extra.drupal-core-project-message --no-interaction
lando composer config --unset homepage --no-interaction
lando composer config --unset support --no-interaction
# TODO: Replace this Drush 14 development branch and its temporary Composer
# dependency workarounds once a stable Drush release supports Drupal 12/Symfony 8.
# The Code Generator Symfony 8 branch has no 4.x alias, so expose it as the
# 4.3.x-dev package required by Drush until a compatible release is available.
lando composer config --json repositories.dcg-symfony8 '{"type":"package","package":{"name":"chi-teck/drupal-code-generator","version":"4.3.x-dev","source":{"url":"https://github.com/Chi-teck/drupal-code-generator.git","type":"git","reference":"sym-8"},"require":{"php":">=8.3.0","ext-json":"*","psr/event-dispatcher":"^1.0","psr/log":"^3.0","symfony/console":"^7.4 || ^8","symfony/dependency-injection":"^7.4 || ^8","symfony/filesystem":"^7.4 || ^8","symfony/string":"^7.4 || ^8","twig/twig":"^3.4"}}}' --no-interaction
lando composer require drush/drush:14.x-dev grasmash/yaml-cli:4.x-dev chi-teck/drupal-code-generator:4.3.x-dev --with-all-dependencies --no-interaction
lando composer config allow-plugins.tbachert/spi true --no-interaction
lando composer require drupal/core-dev:^12@beta --dev --with-all-dependencies --no-interaction
lando composer config allow-plugins.cweagans/composer-patches true --no-interaction
lando composer require cweagans/composer-patches:~2.0 --no-interaction

cd ..
mv drupal12/{.[!.],}* .
rm -rf drupal12

cp "$scriptDir/templates/.gitignore" .gitignore

create_agents_file "Drupal 12"

lando rebuild -y

mkdir -p config/sync web/sites/default/files
cp web/sites/default/default.settings.php web/sites/default/settings.php
echo "\$settings['config_sync_directory'] = '../config/sync';" >> web/sites/default/settings.php
# TODO: Update these database credentials when this switches to Lando's Drupal 12 recipe.
lando drush site-install --account-pass=admin --db-url=mysql://drupal11:drupal11@database/drupal11 --site-name=$appName --yes

# These starter modules have releases that declare Drupal 12 compatibility.
lando composer require drupal/navigation_extra_tools:^1.3 --no-interaction
lando composer require drupal/devel:^5.5 drupal/module_filter:^6.0 --dev --no-interaction
# TODO: Add drupal/coffee and drupal/fpa once compatible Drupal 12 releases are available.
lando drush pm-enable devel devel_generate module_filter navigation_extra_tools --yes

lando db-export initial.sql

lando drush cex --yes
git init
git add .
git commit -m "Initial commit"

echo "Drupal 12 is installed and available at: https://$appName.lndo.site"
