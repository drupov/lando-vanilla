# Lando Vanilla Drupal

Launch a vanilla Drupal (10, 11 or CMS) or create a PHP playground with Lando with one command.

Also launching a node app is supported, but consider using [NVM](https://github.com/nvm-sh/nvm) for that.

## Requirements

All you need is L...ando. See https://docs.lando.dev/install.

## Usage

Launch an app in a Lando docker container quickly by provinding a short command (replace `app-name` with something that makes sense in your case), e.g.

```
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

- Drupal 11 and Drupal CMS have no `fpa` module, as it has a console error, `Uncaught TypeError: Drupal.behaviors.permissions is undefined`.
- Drupal CMS has is not using `admin_toolbar` anymore.
