<?php
/*
Plugin Name: S3 Uploads Filter
*/

add_filter( 's3_uploads_s3_client_params', function ( $params ) {

	if ( defined( 'S3_UPLOADS_ENDPOINT' ) ) {
		$params['endpoint'] = S3_UPLOADS_ENDPOINT;
	}

	if ( defined( 'S3_USE_PATH_STYLE_ENDPOINT' ) ) {
		$params['use_path_style_endpoint'] = S3_USE_PATH_STYLE_ENDPOINT;
	}

	if ( defined( 'WP_DEBUG' ) ) {
		$params['debug'] = WP_DEBUG;
	}

	return $params;

}, 5, 1 );