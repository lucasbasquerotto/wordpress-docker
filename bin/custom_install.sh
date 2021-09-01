#!/bin/bash
set -eou pipefail

echo "$(date '+%F %X') Custom install - Start"

APP_DIR=/var/www/html/web/app
TMP_BASE_DIR=/var/www/html/tmp/dl/
TMP_DL_DIR=/tmp/main/composer/dl

function download {
	name="$1"
	version="$2"
	url="$3"
	type="$4"
	full_base_dir="$APP_DIR/$type"
	full_dir="$full_base_dir/$name"
	tmp_dir="$TMP_BASE_DIR/$type"
	tmp_file="$tmp_dir/$name"

	current_version=""

	if [ -f "$tmp_file" ]; then
		current_version="$(cat "$tmp_file")"
	fi

	if [ "$current_version" != "$version" ] || [ ! -d "$full_dir" ]; then
		if [ -d "$full_dir" ]; then
			echo "$(date '+%F %X') [$type] remove old directory (${name})..."
			rm -rf "${full_dir:?}"
		fi

		echo "$(date '+%F %X') [$type] download ${name} (${version})..."

		mkdir -p "$full_base_dir"
		mkdir -p "$TMP_DL_DIR"

		curl -L "$url" -o "$TMP_DL_DIR/${name}.zip"

		unzip "$TMP_DL_DIR/${name}.zip" -d "$full_base_dir"
		rm "$TMP_DL_DIR/${name}.zip"

		chown -R www-data:www-data "$full_base_dir"

		mkdir -p "$tmp_dir"
		echo "$version" > "$tmp_file"

		echo "$(date '+%F %X') [$type] ${name} (${version}) downloaded"
	else
		echo "$(date '+%F %X') [$type] ${name} already downloaded"
	fi
}

function download_plugin {
	name="$1"
	version="$2"
	url="https://downloads.wordpress.org/plugin/${name}.${version}.zip"
	download "$name" "$version" "$url" "plugins"
}

function download_theme {
	name="$1"
	version="$2"
	url="https://downloads.wordpress.org/theme/${name}.${version}.zip"
	download "$name" "$version" "$url" "themes"
}

echo "$(date '+%F %X') download plugins..."

download_plugin "akismet" "4.1.11"

download_plugin "amazon-s3-and-cloudfront" "2.5.5" # WP Offload Media Lite (S3)

download_plugin "bbpress" "2.6.6"

download_plugin "buddypress" "9.1.1"

download_plugin "contact-form-7" "5.4.2"

download_plugin "disqus-comment-system" "3.0.22"

download_plugin "ewww-image-optimizer" "6.2.4"

download_plugin "jetpack" "10.0"

# download_plugin "leadin" "7.41.0" # Hubspot

### w3-total-cache - start ###
download_plugin "w3-total-cache" "2.1.6"

cp "$APP_DIR"/plugins/w3-total-cache/wp-content/advanced-cache.php \
	"$APP_DIR"/advanced-cache.php
chown www-data:www-data "$APP_DIR"/advanced-cache.php

mkdir -p "$APP_DIR"/cache
chown www-data:www-data "$APP_DIR"/cache

mkdir -p "$APP_DIR"/w3tc-config
chown www-data:www-data "$APP_DIR"/w3tc-config
### w3-total-cache - end ###

download_plugin "woocommerce" "5.6.0"

download_plugin "wordpress-importer" "0.7"

download_plugin "wordpress-seo" "17.0" # Yoast SEO

download_plugin "wpdiscuz" "7.2.2"

download_plugin "wpforo" "1.9.9"

download_plugin "wp-mail-smtp" "3.0.3"

echo "$(date '+%F %X') plugins downloaded"

echo "$(date '+%F %X') download themes..."

download_theme "maxwell" "2.3.4"

download_theme "ascent" "3.8.7"

download_theme "cordero" "1.2.3"

download_theme "clean-commerce" "1.2"

echo "$(date '+%F %X') themes downloaded"