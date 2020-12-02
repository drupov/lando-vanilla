# Launch a vanilla Lando app with one command

## Requirements

All you need is l...ando. See https://docs.lando.dev/basics/installation.html.

## Usage

Launch an app in a lando docker container quickly by provinding a short command (replace `app-name` with something that makes sense in your case), e.g.

```
# Drupal 7
scripts/drupal7.sh -n app-name

# Drupal 8
scripts/drupal8.sh -n app-name

# Drupal 9
scripts/drupal9.sh -n app-name -s

# Drupal 8, only setup and Lando start, useful for distribution installation afterwards
scripts/drupal8.sh -n app-name -s

# Node
scripts/node.sh -n app-name
```
