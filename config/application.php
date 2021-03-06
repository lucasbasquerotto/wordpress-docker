<?php
/**
 * Your base production configuration goes in this file. Environment-specific
 * overrides go in their respective config/environments/{{WP_ENV}}.php file.
 *
 * A good default policy is to deviate from the production config as little as
 * possible. Try to define as much of your configuration in this file as you
 * can.
 */

use Roots\WPConfig\Config;
use function Env\env;

/**
 * Directory containing all of the site's files
 *
 * @var string
 */
$root_dir = dirname(__DIR__);

/**
 * Document Root
 *
 * @var string
 */
$webroot_dir = $root_dir . '/web';

/**
 * Use Dotenv to set required environment variables and load .env file in root
 */
$dotenv = Dotenv\Dotenv::createUnsafeImmutable($root_dir);
if (file_exists($root_dir . '/.env')) {
    $dotenv->load();
    $dotenv->required(['WP_HOME', 'WP_SITEURL']);
    if (!env('DATABASE_URL')) {
        $dotenv->required(['DB_NAME', 'DB_USER', 'DB_PASSWORD']);
    }
}

/**
 * Set up our global environment constant and load its config first
 * Default: production
 */
define('WP_ENV', env('WP_ENV') ?: 'production');

/**
 * URLs
 */
Config::define('WP_HOME', env('WP_HOME'));
Config::define('WP_SITEURL', env('WP_SITEURL'));

/**
 * Custom Content Directory
 */
Config::define('CONTENT_DIR', '/app');
Config::define('WP_CONTENT_DIR', $webroot_dir . Config::get('CONTENT_DIR'));
Config::define('WP_CONTENT_URL', Config::get('WP_HOME') . Config::get('CONTENT_DIR'));

/**
 * DB settings
 */
Config::define('DB_NAME', env('DB_NAME'));
Config::define('DB_USER', env('DB_USER'));
Config::define('DB_PASSWORD', env('DB_PASSWORD'));
Config::define('DB_HOST', env('DB_HOST') ?: 'localhost');
Config::define('DB_CHARSET', 'utf8mb4');
Config::define('DB_COLLATE', '');
$table_prefix = env('DB_PREFIX') ?: 'wp_';

if (env('DATABASE_URL')) {
    $dsn = (object) parse_url(env('DATABASE_URL'));

    Config::define('DB_NAME', substr($dsn->path, 1));
    Config::define('DB_USER', $dsn->user);
    Config::define('DB_PASSWORD', isset($dsn->pass) ? $dsn->pass : null);
    Config::define('DB_HOST', isset($dsn->port) ? "{$dsn->host}:{$dsn->port}" : $dsn->host);
}

/**
 * Authentication Unique Keys and Salts
 */
Config::define('AUTH_KEY', env('AUTH_KEY'));
Config::define('SECURE_AUTH_KEY', env('SECURE_AUTH_KEY'));
Config::define('LOGGED_IN_KEY', env('LOGGED_IN_KEY'));
Config::define('NONCE_KEY', env('NONCE_KEY'));
Config::define('AUTH_SALT', env('AUTH_SALT'));
Config::define('SECURE_AUTH_SALT', env('SECURE_AUTH_SALT'));
Config::define('LOGGED_IN_SALT', env('LOGGED_IN_SALT'));
Config::define('NONCE_SALT', env('NONCE_SALT'));

/**
 * Custom Settings
 */
Config::define('AUTOMATIC_UPDATER_DISABLED', true);
Config::define('DISABLE_WP_CRON', env('DISABLE_WP_CRON') ?: false);
// Disable the plugin and theme file editor in the admin
Config::define('DISALLOW_FILE_EDIT', true);
// Disable plugin and theme updates and installation from the admin
Config::define('DISALLOW_FILE_MODS', true);
// Limit the number of post revisions that Wordpress stores (true (default WP): store every revision)
Config::define('WP_POST_REVISIONS', env('WP_POST_REVISIONS') ?: true);

/**
 * Debugging Settings
 */
Config::define('WP_DEBUG_DISPLAY', false);
Config::define('WP_DEBUG_LOG', env('WP_DEBUG_LOG') ?? false);
Config::define('SCRIPT_DEBUG', false);
ini_set('display_errors', '0');

/**
 * Allow WordPress to detect HTTPS when used behind a reverse proxy or a load balancer
 * See https://codex.wordpress.org/Function_Reference/is_ssl#Notes
 */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

/////////////////////////////////////////////
////////// Custom Settings - Start //////////
/////////////////////////////////////////////

Config::define('WP_DEBUG', env('WP_DEBUG'));
Config::define('WP_DEBUG_LOG', env('WP_DEBUG'));

if (env('USE_W3TC')) {
    // Persist W3 Total Cache settings to the database
    Config::define('WP_CACHE', true);
    Config::define('W3TC_CONFIG_DATABASE', true);
    Config::define('W3TC_CONFIG_DATABASE_TABLE', $table_prefix . 'options');
}

if (defined('WP_CLI') && WP_CLI) {
    if (!isset($_SERVER['SERVER_NAME'])) {
        $_SERVER['SERVER_NAME'] = 'wordpress';
    }
}

if (env('USE_S3_UPLOADS')) {
    define('S3_UPLOADS_BUCKET', env('S3_UPLOADS_BUCKET'));
    define('S3_UPLOADS_REGION', env('S3_UPLOADS_REGION'));

    define('S3_UPLOADS_KEY', env('S3_UPLOADS_KEY'));
    define('S3_UPLOADS_SECRET', env('S3_UPLOADS_SECRET'));

    define('S3_UPLOADS_BUCKET_URL', env('S3_UPLOADS_BUCKET_URL'));

    define('S3_UPLOADS_ENDPOINT', env('S3_UPLOADS_ENDPOINT'));
    define('S3_USE_PATH_STYLE_ENDPOINT', env('S3_USE_PATH_STYLE_ENDPOINT'));

    define('AS3CF_SETTINGS', serialize(array(
        'provider' =>  env('S3_PROVIDER') || 'aws',
        'access-key-id' => env('S3_UPLOADS_KEY'),
        'secret-access-key' => env('S3_UPLOADS_SECRET'),
        'bucket' => env('S3_UPLOADS_BUCKET'),
        'region' => env('S3_UPLOADS_REGION'),
        'enable-object-prefix' => false,
        // Automatically copy files to bucket on upload
        'copy-to-s3' => true,
        // Organize bucket files into YYYY/MM directories matching Media Library upload date
        'use-yearmonth-folders' => true,
        // Append a timestamped folder to path of files offloaded to bucket to avoid filename clashes and bust CDN cache if updated
        'object-versioning' => true,
        // Use a custom domain (CNAME), not supported when using 'storage' Delivery Provider
        'enable-delivery-domain' => !!env('S3_UPLOADS_BUCKET_URL'),
        // Custom domain (CNAME), not supported when using 'storage' Delivery Provider
        'delivery-domain' => env('S3_UPLOADS_BUCKET_URL'),
    )));
}

/////////////////////////////////////////////
/////////// Custom Settings - End ///////////
/////////////////////////////////////////////

$env_config = __DIR__ . '/environments/' . WP_ENV . '.php';

if (file_exists($env_config)) {
    require_once $env_config;
}

Config::apply();

/**
 * Bootstrap WordPress
 */
if (!defined('ABSPATH')) {
    define('ABSPATH', $webroot_dir . '/wp/');
}
