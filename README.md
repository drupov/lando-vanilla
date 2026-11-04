# Lando Vanilla Drupal

Launch a vanilla Drupal (10, 11 or CMS) or create a PHP playground with Lando with one command.

Drupal 10 and 11 projects use the official `drupal/recommended-project` Composer template.
Drupal CMS projects use the official `drupal/cms` Composer project.

Also launching a node app is supported, but consider using [NVM](https://github.com/nvm-sh/nvm) for that.

## Requirements

All you need is L...ando. See https://docs.lando.dev/install.

## Usage

Launch an app in a Lando docker container quickly by provinding a short command (replace `app-name` with something that makes sense in your case), e.g.

```
# Drupal 11 (using drupal/recommended-project)
/path/to/scripts/drupal11.sh -n app-name

# Drupal CMS (using drupal/cms)
/path/to/scripts/drupalcms.sh -n app-name

# Lando-only Drupal 11 environment (does not download or install Drupal)
# Useful when you will install a custom distribution or codebase yourself.
/path/to/scripts/drupal11.sh -n app-name -s

# Drupal 10 (using drupal/recommended-project)
/path/to/scripts/drupal10.sh -n app-name

# Node
/path/to/scripts/node.sh -n app-name

# PHP
/path/to/scripts/php.sh -n app-name
```
