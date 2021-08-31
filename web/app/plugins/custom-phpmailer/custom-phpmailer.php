<?php
/*
Plugin Name: Custom Phpmailer
Description: Use SMTP credentials define in the config.php file to send emails.
Author: Lucas Basquerotto
Version: 1.0.0
*/

use function Env\env;

class CustomPhpmailer {

	function __construct() {
		if (env('USE_CUSTOM_SMTP_SETTINGS')) {
			/**
			* This function will connect wp_mail to your authenticated
			* SMTP server. Values are constants set in wp-config.php
			*/
			add_action( 'phpmailer_init', 'send_smtp_email' );
			function send_smtp_email( $phpmailer ) {
				$phpmailer->isSMTP();
				$phpmailer->Host       = env('SMTP_HOST');
				$phpmailer->SMTPAuth   = env('SMTP_AUTH');
				$phpmailer->Port       = env('SMTP_PORT');
				$phpmailer->Username   = env('SMTP_USER');
				$phpmailer->Password   = env('SMTP_PASS');
				$phpmailer->SMTPSecure = env('SMTP_SECURE');
				$phpmailer->From       = env('SMTP_FROM');
				$phpmailer->FromName   = env('SMTP_NAME');
			}
		}
	}
}

new CustomPhpmailer();