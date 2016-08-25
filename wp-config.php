<?php
define( 'DB_NAME', '{DB_NAME}' );
define( 'DB_USER', '{DB_USER}' );
define( 'DB_PASSWORD', '{DB_PASS}' );
define( 'DB_HOST', 'localhost' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

// https://api.wordpress.org/secret-key/1.1/salt
define('AUTH_KEY',         '.|+x]@|N.+ml2wvd2mJz(^A$@{d`|Ac|Z5(0<W6+|lD,-M)v2PTtJS)YP+Bwu/<y');
define('SECURE_AUTH_KEY',  'yYNJ+R1+jhd?9t)OcKhJ)+888aWW9J*ou)mJNF)*_u&x`+ 7:0.?~SiuF1?u+Osk');
define('LOGGED_IN_KEY',    'F>IhI/<F{|,t2[|4G`(AaowW+~:Ay(+ua~n:@J?b$CY{)#,|Vs-2u[:8e*>OT;R,');
define('NONCE_KEY',        '54u0Kkiqw,cSSudxzSrhUHi#swU_WA|ox/V8~ATR(p4|4kW^UV6eLMOzzc8zjR6J');
define('AUTH_SALT',        '|Q9[{b;:b!QoT`-9xdKF#dJ{&yp^r+%YJlE8|##b.4bYnJR60&1Nq6e{-&<E15pf');
define('SECURE_AUTH_SALT', 'AA563rR|-<@(M3qk(&yQ5X?)}u[xx`Hjy2v:.1@Gy7g}rk*k-aW81Etz{lJ}V%@q');
define('LOGGED_IN_SALT',   '5WMS&o*}]7Ua`{|h^LIsv)jixD7%nMt%b-nd:R){|>__@`H*-mxi-$,b6#.R]8l?');
define('NONCE_SALT',       '(:D3w66)E-8F~`&}jl:|-~-PL]^e!,-5r[Yf}ROfaP]:yE<<S(J~=v5lbTVhX7EK');

// Table prefix.
$table_prefix  = '{TABLE_PREFIX}';

// Debugging mode.
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'SCRIPT_DEBUG', true );

@ini_set( 'log_errors', 'On' );
@ini_set( 'display_errors', 'Off' );

// Compression
define( 'COMPRESS_CSS', true );
define( 'COMPRESS_SCRIPTS', true );
define( 'CONCATENATE_SCRIPTS', true );
define( 'ENFORCE_GZIP', true );

// Updates
define( 'WP_AUTO_UPDATE_CORE', false );
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'DISALLOW_FILE_EDIT', true );

// Performance
define( 'WP_SITEURL', 'http://{SITE_URL}' );
define( 'WP_HOME', 'http://{SITE_URL}' );

// Post revision
define( 'WP_POST_REVISIONS', false );

//Memory limit
define( 'WP_MAX_MEMORY_LIMIT', '256M' );

// Absolute path to the WordPress directory.
if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );

// Sets up WordPress vars and included files.
require_once( ABSPATH . 'wp-settings.php' );
