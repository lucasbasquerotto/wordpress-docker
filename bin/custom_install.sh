#!/bin/bash
set -eou pipefail

echo "$(date '+%F %X') Custom install - Start"

APP_DIR=/var/www/html/web/app
PLUGINS_DIR="$APP_DIR/plugins"

function download {
	name="$1"
	version="$2"
	url="https://downloads.wordpress.org/plugin/${name}.${version}.zip"

	if [ ! -d "$PLUGINS_DIR/${name}" ]; then
		echo "$(date '+%F %X') download ${name} (${version})..."

		mkdir -p "$PLUGINS_DIR"

		curl -L "$url" -o "/tmp/${name}.zip"

		unzip "/tmp/${name}.zip" -d "$PLUGINS_DIR"
		rm "/tmp/${name}.zip"

		chown -R www-data:www-data "$PLUGINS_DIR"

		echo "$(date '+%F %X') ${name} (${version}) downloaded"
	else
		echo "$(date '+%F %X') ${name} already downloaded"
	fi
}

### w3-total-cache - start ###
download "w3-total-cache" "0.14.4"

cp "$PLUGINS_DIR"/w3-total-cache/wp-content/advanced-cache.php \
	"$APP_DIR"/advanced-cache.php
chown www-data:www-data "$APP_DIR"/advanced-cache.php

mkdir -p "$APP_DIR"/cache
chown www-data:www-data "$APP_DIR"/cache

mkdir -p "$APP_DIR"/w3tc-config
chown www-data:www-data "$APP_DIR"/w3tc-config
### w3-total-cache - end ###

download "contact-form-7" "5.2.2"

download "jetpack" "8.8.2"

download "akismet" "4.1.6"

download "ewww-image-optimizer" "5.7.0"

download "amazon-s3-and-cloudfront" "2.4.1"

echo "$(date '+%F %X') Custom install - End"