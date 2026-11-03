# {{DRUPAL_PROJECT}} Project

## Overview
- {{DRUPAL_PROJECT}} project managed with Composer and Lando.
- Web root: `web/`
- PHP dependencies: `vendor/`
- Drupal configuration: `config/sync/`

## Project Structure
- Custom modules: `web/modules/custom/`
- Custom themes: `web/themes/custom/`
- Drupal core: `web/core/`

## Development Guidelines
- Follow Drupal coding standards and APIs.
- Use dependency injection and respect cache metadata.
- Use configuration management for deployable settings.
- Never modify Drupal core or contributed modules directly.
- Use Composer to manage PHP dependencies.

## Commands
- Run Drush commands through Lando: `lando drush <command>`.

## Safety
- Never commit credentials or secrets.
- Do not execute destructive database operations without approval.
- Do not overwrite existing configuration without checking its impact.
