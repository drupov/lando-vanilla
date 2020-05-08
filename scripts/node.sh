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
echo "services:" >> .lando.yml
echo "  appserver:" >> .lando.yml
echo "    type: node" >> .lando.yml
echo "    overrides:" >> .lando.yml
echo "      ports:" >> .lando.yml
echo "        - 3000:3000" >> .lando.yml
echo "    globals:" >> .lando.yml
echo "      gulp-cli: latest" >> .lando.yml
echo "tooling:" >> .lando.yml
echo "  npm:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "  node:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "  npx:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "  yarn:" >> .lando.yml
echo "    service: appserver" >> .lando.yml
echo "  gulp:" >> .lando.yml
echo "    service: appserver" >> .lando.yml

lando start
