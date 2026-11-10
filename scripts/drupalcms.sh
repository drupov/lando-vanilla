#!/bin/bash

set -eo pipefail

scriptDir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$scriptDir/_bootstrap.sh"

prepare_app_directory "n:s" "$@"

echo "name: $appName" >> .lando.yml
echo "recipe: drupal11" >> .lando.yml
echo "config:" >> .lando.yml
echo "  via: nginx" >> .lando.yml
echo "  webroot: web" >> .lando.yml
echo "  php: 8.5" >> .lando.yml
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

echo "memory_limit = 256M" >> php.ini
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

lando composer create-project drupal/cms drupalcms --no-interaction --no-install
cd drupalcms
lando composer install

cd ..
mv drupalcms/{.[!.],}* .
rm -rf drupalcms

printf '\n# Database dumps.\n*.sql\n*.sql.gz\n' >> .gitignore

create_agents_file "Drupal CMS"

lando drush site-install --account-pass=admin --db-url=mysql://drupal11:drupal11@database/drupal11 --site-name=$appName --yes

chmod 755 web/sites/default

lando composer require drupal/coffee --no-interaction
lando composer require drupal/devel drupal/module_filter drupal/fpa --dev --no-interaction
lando drush pm-enable coffee devel devel_generate module_filter fpa --yes

sed -i 's/^memory_limit = 256M$/memory_limit = 128M/' php.ini
lando restart

lando db-export initial.sql

lando drush cex --yes
git init
git add .
git commit -m "Initial commit"

echo "Drupal CMS is installed and available at: https://$appName.lndo.site"
