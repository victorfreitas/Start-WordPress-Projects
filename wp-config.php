<?php
const DB_NAME     = '{DB_NAME}';
const DB_USER     = '{DB_USER}';
const DB_PASSWORD = '{DB_PASS}';
const DB_HOST     = 'localhost';
const DB_CHARSET  = 'utf8';
const DB_COLLATE  = '';

/**
 * Secret keys
 *
 * @link https://api.wordpress.org/secret-key/1.1/salt/
 */
define('AUTH_KEY',         '_@ZHWMh*(nn~Nf:9L1uSH~IfCW>4}F1,nw`0rkH/(lW*|w>Ie;^O;~|hN_!1!# >');
define('SECURE_AUTH_KEY',  '2/PJXoOXa9(Q86;VpEGlT`*9(k$GeyUrf3VY$cSdEQF+ %Ig{nq4g6X/LMZjj&(b');
define('LOGGED_IN_KEY',    'x[Ja@CjRSR7Q#^xhj=Q;BU.E;stYg8O&.Y0=s1A9$GKp&<ST:0C -Aorf)`~[;nW');
define('NONCE_KEY',        '%zb$&J@L9,%k HmxQ||3xnH&g q r*44^OBi|rm/jMG5<9m)#,J|n<p3L756&{:{');
define('AUTH_SALT',        '@p`Px5N=uSkl}tt~Ij;ZwB#wF#X.~Y=dvzh~tz=*-c.N(zgZ^|A!>U/|hj-^&89v');
define('SECURE_AUTH_SALT', 'n>|JC,b7V<%661kx4*}`&<xy,X+ywh2bXjY-hM[;-R!%-Xq:?I^KVcXQ0~!`*i`H');
define('LOGGED_IN_SALT',   'BUZ&jx#|jOuH~}>X+J/F$Nd*r<3a~M6IY|OW7r^;/=-?{BF:Uab|`_rbYsL{]&8C');
define('NONCE_SALT',       'F[+HRDT=fcADq7q1eIvl+Yp^&brj.Hc- H)`8tFZZEap_![wJ:[*K-S$[*U=$d~V');

// Table prefix.
$table_prefix = '{TABLE_PREFIX}';

/**
 * Debugging mode
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
const WP_DEBUG = true;
const WP_DEBUG_LOG = true;
const WP_DEBUG_DISPLAY = false;
const SCRIPT_DEBUG = true;
const SAVEQUERIES = true;

@ini_set( 'log_errors', 'On' );
@ini_set( 'display_errors', 'Off' );

// Compression
const COMPRESS_CSS        = true;
const COMPRESS_SCRIPTS    = true;
const CONCATENATE_SCRIPTS = true;
const ENFORCE_GZIP        = true;

// Updates
const WP_AUTO_UPDATE_CORE = false;
const AUTOMATIC_UPDATER_DISABLED = true;
const DISALLOW_FILE_EDIT  = true;

// Performance
const WP_SITEURL = 'http://{SITE_URL}';
const WP_HOME    = 'http://{SITE_URL}';

// Post revision
const WP_POST_REVISIONS = false;

//Memory limit
const WP_MAX_MEMORY_LIMIT = '256M';

// Absolute path to the WordPress directory.
if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );

// Sets up WordPress vars and included files.
require_once( ABSPATH . 'wp-settings.php' );