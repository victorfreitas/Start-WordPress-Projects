#!/bin/bash
#!/bin/sed -f

dir_name=$(dirname $0)

source "$dir_name/helpers/utils.sh"
source "$dir_name/functions.sh"

# Setings default variables
set_defaults_variables $1 $2

# Importing variable of configurations.
importing_variables $dir_name

# Verifying necessary params
verifying_params $site $db_name

## Verifying vhost file exists ##
check_vhosts_exits $VHOSTS_FILE

# Directory exists exit
dir_exists "Could not create the project because it already exists."

# Database exists exit
database_exists $db_name

echo -n "Import database? [y/n]: "
read is_import_db

if [ "$is_import_db" = 'y' ]; then
	echo -n "Inform absolute path to file .sql: "
	read file_sql

	# File not exists exit
	file_not_exists $file_sql

	echo -n "Replace url WordPress DB? [y/n]: "
	read is_replace
fi

if [ "$is_replace" = 'y' ]; then
	echo -n "Inform url to search: "
	read url_search

	# Is empty url exit
	is_empty $url_search "Url is empty, aborting process."
fi

echo -n "Clone project from git? [y/n]: "
read is_clone

if [ "$is_clone" = 'y' ]; then
	echo -n "Inform your url from git: "
	read git_url

	echo "=== Clonning project"
	git clone $git_url $root
fi

# Not success clone project exit
is_clonning_not_success $root $is_clone

if [ "$is_clone" != 'y' ]; then
	echo -n "Import an existing project in directory? [y/n]: "
	read is_import_existing

	if [ "$is_import_existing" = 'y' ]; then
		echo -n "Enter an absolute directory: "
		read existing_project

		# Import project existing
		importing_existing_project "$existing_project"
	fi
fi

if [ ! -d "$root" ]; then
	echo "=== Creating directory root"
	mkdir "$root"

	if [ ! -d "$root" ]; then
		exit_proccess '=== Error while trying to create project directory.'
	fi

	echo "[Done]"
fi

echo "=== Writing in vhosts"
sudo su -c\
"cat << EOF >> $VHOSTS_FILE
# BEGIN $site
<VirtualHost *:80>
    DocumentRoot $root
    ServerName $site
    ServerAlias www.$site
</VirtualHost>
# END $site
EOF"
echo "[Done]"

echo "=== Writing in hosts"
sudo su -c\
"cat << EOF >> /etc/hosts
$IP $site www.$site
EOF"
echo "[Done]"

if [ "$db_name" ]; then
	echo "=== Creating database"
    echo "CREATE DATABASE IF NOT EXISTS $db_name;" | mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST"
    echo "[Done]"
fi

if [ "$is_import_db" = 'y' ]; then
	installing_database $file_sql

	echo -n "Inform prefix your tables: "
	read prefix_table
fi

if [[ "$is_replace" = 'y' ]] && [[ "$is_import_db" = 'y' ]]; then
	echo "=== Init replace urls from database"
	replace_url $url_search
	echo "[Done]"
fi

if [[ "$is_clone" != 'y' ]] && [[ "$is_import_existing" != 'y' ]]; then
	echo -n "Install WordPress? [y/n]: "
	read install_wp
fi

echo -n "Instalation with multisite? [y/n]: "
read is_multisite

if [ "$is_multisite" = 'y' ]; then
	echo -n "Is multisite subdomain? [y/n]: "
	read is_subdomain
fi

echo -n "Deseja criar as tabelas no banco de dados? [y/n]: "
read is_db_install

if [ "$is_db_install" = 'y' ]; then
	setting_database
fi

if [ "$install_wp" = 'y' ]; then
	download_latest_wordpress
	setting_database

	echo "=== Copying files WordPress"
	# Copying WordPress files to root path
	rsync -az --exclude-from="$dir_name/.rsyncignore" "$dir_name/wordpress/"* $root
	echo "[Done]"
fi

echo "=== Creating htaccess"
# Copy htacess to root path

if [ "$is_multisite" = 'y' ]; then
	htaccess_file="$dir_name/multisitesf-htaccess"

	if [ "$is_subdomain" = 'y' ]; then
		htaccess_file="$dir_name/multisitesd-htaccess"
	fi

	cp $htaccess_file "$root/.htaccess"
fi

if [ "$is_multisite" != 'y' ]; then
	cp "$dir_name/.htaccess" "$root/.htaccess"
fi

echo "[Done]"
echo "=== Creating wp-config.php"

MULTISITE_CONSTANTS=''

if [ "$is_multisite" = 'y' ]; then
	IS_SUBDOMAIN='false'

	if [ "$is_subdomain" = 'y' ]; then
		IS_SUBDOMAIN='true'
	fi

MULTISITE_CONSTANTS="\n\
\/\/ Multisite\n\
define( 'WP_ALLOW_MULTISITE', true );\n\
define( 'MULTISITE', true );\n\
define( 'SUBDOMAIN_INSTALL', $IS_SUBDOMAIN );\n\
define( 'DOMAIN_CURRENT_SITE', _CURRENT_SITE_DOMAIN );\n\
define( 'PATH_CURRENT_SITE', '\/' );\n\
define( 'SITE_ID_CURRENT_SITE', 1 );\n\
define( 'BLOG_ID_CURRENT_SITE', 1 );"
fi

# Search and replace mysql settings in wp config
sed -e "
s/{DB_NAME}/$DB_NAME/g;
s/{DB_USER}/$DB_USER/g;
s/{DB_PASS}/$DB_PASS/g;
s/{DB_HOST}/$DB_HOST/g;
s/{DB_CHARSET}/$DB_CHARSET/g;
s/{TABLE_PREFIX}/$prefix_table/g;
s/{SITE_URL}/$site/g;
s/\/\/{MULTISITE}/$MULTISITE_CONSTANTS/g" $dir_name/$WP_CONFIG_FILE > $root/$WP_CONFIG_FILE

echo "[Done]"
echo "=== Setting permissions in the directory"
# Set permissions
sudo chown -R $perm $root
find $root -type d -exec chmod 755 {} \;
find $root -type f -exec chmod 644 {} \;
echo "[Done]"

restart_server

if [ "$is_db_installed" = 'y' ]; then
	echo "=== WordPress admin user: $WP_USER"
	echo "=== WordPress admin password: admin"
fi

echo "=== Successfully create site: http://$site"