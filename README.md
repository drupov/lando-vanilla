# Launch a Vanilla Lando App With One Command

## Requirements

All you need is L...ando. See https://docs.lando.dev/basics/installation.html.

## Usage

Launch an app in a Lando docker container quickly by provinding a short command (replace `app-name` with something that makes sense in your case), e.g.

```
# Drupal 7
scripts/drupal7.sh -n app-name

# Drupal 9
scripts/drupal9.sh -n app-name

# Drupal 9, only setup and Lando start, useful for distribution installation afterwards
scripts/drupal9.sh -n app-name -s

# Node
scripts/node.sh -n app-name
```

Note: Drupal 8 is EOL, it is not available anymore.
