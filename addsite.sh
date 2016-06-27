#!/bin/sh
#!/bin/bash
#!/bin/sed -f

dir_name=$(dirname $0)

source "$dir_name/helpers/utils.sh"
source "$dir_name/functions.sh"

# Importing variable of configurations.
importing_variables $dir_name

# Setings default variables
set_defaults_variables $1 $2

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
	notice_for_ssh_git
fi

if [ "$is_clone" = 'y' ]; then
	echo -n "Inform your url from git: "
	read git_url

	echo "=== Clonning project"
	git clone "$git_url" "$root"
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

echo "=== Writing in vhosts"
cat << EOF >> "$VHOSTS_FILE"
# BEGIN $site
<VirtualHost *:80>
    DocumentRoot $root
    ServerName $site
    ServerAlias www.$site
</VirtualHost>
# END $site
EOF
echo "[Done]"

echo "=== Writing in hosts"
cat << EOF >> /etc/hosts
$IP $site www.$site
EOF
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
	echo "=== Init replace database"
	replace_url $url_search
	echo "[Done]"
fi

if [ ! -d "$root" ]; then
	echo "=== Creating directory root"
	mkdir $root
	echo "[Done]"
fi

if [[ "$is_clone" != 'y' ]] && [[ "$is_import_existing" != 'y' ]]; then
	echo -n "Install WordPress? y/n: "
	read install_wp
fi

if [ "$install_wp" = 'y' ]; then
	download_latest_wordpress
	setting_database

	echo "=== Copying files WordPress"
	# Copying WordPress files to root path
	rsync -azv --progress --exclude-from="$dir_name/.rsyncignore" "$dir_name/wordpress/"* $root
	echo "[Done]"
fi

echo "=== Creating wp-config.php"
# Search and replace mysql settings in wp config
sed -e "s/{TABLE_PREFIX}/$prefix_table/g;s/{DB_NAME}/$db_name/g;s/{DB_USER}/$DB_USER/g;s/{DB_PASS}/$DB_PASS/g;s/{SITE_URL}/$site/g" $dir_name/$WP_CONFIG_FILE > $root/$WP_CONFIG_FILE
echo "[Done]"

echo "=== Creating htaccess"
# Copy htacess to root path
cp "$dir_name/.htaccess" "$root/.htaccess"
echo "[Done]"

echo "=== Setting permissions in the directory"
# Set permissions
find $root -type d -exec chmod 755 {} \;
find $root -type f -exec chmod 644 {} \;
chown -R $perm $root
echo "[Done]"

restart_server

if [[ "$install_wp" = 'y' ]] && [[ "$is_import_db" != 'y' ]]; then
	echo "=== WordPress admin user: admin"
	echo "=== WordPress admin password: admin"
fi

echo "=== Successfully create site: http://$site"