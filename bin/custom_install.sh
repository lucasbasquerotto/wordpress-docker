#!/bin/bash
set -eou pipefail

echo "$(date '+%F %X') Custom install - Start"

W3TC_VERSION=0.14.4
APP_DIR=/var/www/html/web/app
PLUGINS_DIR="$APP_DIR/plugins"
W3TC_URL="https://downloads.wordpress.org/plugin/w3-total-cache.${W3TC_VERSION}.zip"

if [ ! -d "$PLUGINS_DIR/w3-total-cache" ]; then
	mkdir -p "$PLUGINS_DIR"

	curl -L "$W3TC_URL" -o /tmp/w3-total-cache.zip

	unzip /tmp/w3-total-cache.zip -d "$PLUGINS_DIR"
	rm /tmp/w3-total-cache.zip

	chown -R www-data:www-data "$PLUGINS_DIR"

	cp "$PLUGINS_DIR"/w3-total-cache/wp-content/advanced-cache.php \
		"$APP_DIR"/advanced-cache.php
	chown www-data:www-data "$APP_DIR"/advanced-cache.php

	mkdir -p "$APP_DIR"/cache
	chown www-data:www-data "$APP_DIR"/cache

	mkdir -p "$APP_DIR"/w3tc-config
	chown www-data:www-data "$APP_DIR"/w3tc-config
fi

echo "$(date '+%F %X') Custom install - End"