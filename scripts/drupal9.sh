# The site name should be passed in as a first parameter to the shell script.
appName=$1

mkdir $appName
cd $appName

echo "name: $appName" >> .lando.yml
echo "recipe: drupal8" >> .lando.yml
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
echo "tooling:" >> .lando.yml
echo "  drush:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: drush --root=/app/web" >> .lando.yml
echo "  drupal:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "    cmd: drupal --root=/app/web" >> .lando.yml

lando start

lando composer create-project drupal/recommended-project:^9@dev drupal9 --remove-vcs
mv drupal9/{.[!.],}* .
rm -rf drupal9

lando restart

lando drush site-install --account-pass=admin --db-url=mysql://drupal8:drupal8@database/drupal8 --site-name=$appName --yes

chmod 755 web/sites/default

echo "Browse your site by visiting:"
lando info | grep lndo.site
