# Lando Vanilla Drupal

Launch a vanilla Drupal (7, 9 or 10) or create a PHP playground with Lando with one command.

Also launching a node app is supported, but consider using [NVM](https://github.com/nvm-sh/nvm) for that.

## Requirements

All you need is L...ando. See https://docs.lando.dev/basics/installation.html.

## Usage

Launch an app in a Lando docker container quickly by provinding a short command (replace `app-name` with something that makes sense in your case), e.g.

```
# Drupal 7
scripts/drupal7.sh -n app-name

# Drupal 10
scripts/drupal10.sh -n app-name

# Drupal 10, only setup and Lando start, useful for distribution installation afterwards
scripts/drupal10.sh -n app-name -s

# Drupal 11
scripts/drupal11.sh -n app-name

# Drupal CMS
scripts/drupalcms.sh -n app-name

# Node
scripts/node.sh -n app-name

# PHP
scripts/php.sh -n app-name
```

Notes:

- Drupal 11 has no `coffee` and `fpa` modules as they are not Drupal 11 ready yet.
- Drupal CMS has no `fpa` modules as they are not Drupal 11 ready yet and is not using `admin_toolbar` anymore.
