# The site name should be passed in as a first parameter to the shell script.
appName=$1

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
echo "    cmd: drush --root=/app/web" >> .lando.yml

echo "memory_limit = 512M" >> php.ini

lando start

lando drush pm-download drupal-7 --drupal-project-rename=web

lando restart

lando drush site-install --account-pass=admin --db-url=mysql://drupal7:drupal7@database/drupal7 --site-name=$appName --yes

lando drush pm-disable toolbar overlay --yes
lando drush pm-uninstall toolbar overlay --yes

lando drush pm-download ctools coffee entity entityreference devel views admin_menu token module_filter search_krumo features strongarm diff fpa --yes

lando drush pm-enable coffee page_manager entityreference devel devel_generate views_ui admin_menu_toolbar token module_filter search_krumo features strongarm diff fpa --yes

echo "Browse your site by visiting:"
lando info | grep lndo.site
