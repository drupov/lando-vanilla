#!/bin/bash

noAppNameMessage="Please provide the app name by passing it with the -n parameter."

prepare_app_directory() {
  local optstring=$1
  shift

  OPTIND=1
  while getopts "$optstring" OPTION "$@"; do
    case $OPTION in
    n)
      appName=$OPTARG
      ;;
    s)
      skip=1
      ;;
    *)
      echo "$noAppNameMessage"
      exit 1
      ;;
    esac
  done

  if [ -z "$appName" ]; then
    echo "$noAppNameMessage"
    exit 1
  fi

  if [ -d "$appName" ]; then
    echo "$appName already exists."
    exit 1
  fi

  mkdir "$appName"
  cd "$appName" || exit 1
}
