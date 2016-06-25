#!/bin/sh
#!/bin/bash
#!/bin/sed -f

dir_name=$(dirname $0)

source "$dir_name/messages.conf"
source "$dir_name/helpers/utils.sh"
source "$dir_name/functions.sh"

# Importing variable of configurations.
importing_variables $dir_name

# Setings default variables
set_defaults_variables $1 $2

# Verifying necessary params
verifying_params $site $db_name

# Directory exists exit
dir_exists $root "$MSG_ROOT_EXISTS"

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
	echo -n "Project import from an existing directory? [y/n]: "
	read is_import_existing

	if [ "$is_import_existing" = 'y' ]; then
		echo -n "Enter an absolute directory. "
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
echo "=== Successfully created vhosts"

echo "=== Writing in hosts"
cat << EOF >> /etc/hosts
$IP $site www.$site
EOF
echo "=== Successfully created hosts"

if [ "$db_name" ]; then
	echo "=== Creating database"
    echo "CREATE DATABASE IF NOT EXISTS $db_name;" | mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST"
    echo "=== Successfully created database"
fi

if [ "$is_import_db" = 'y' ]; then
	echo "=== Importing database"
	mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" "$db_name" < "$file_sql"
	echo "=== Successfully importing database"

	echo -n "Inform prefix your tables: "
	read prefix_table
fi

if [[ "$is_replace" = 'y' ]] && [[ "$is_import_db" = 'y' ]]; then
	echo "=== Init replace database"
	"$dir_name/srdb.cli.php" -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -n"$db_name" -s $url_search -r $site
	echo "=== Replace database successful"
fi

if [ ! -d "$root" ]; then
	echo "=== Creating directory root"
	mkdir $root
	echo "=== Successfully created directory root"
fi

if [[ "$is_clone" != 'y' ]] && [[ "$is_import_existing" != 'y' ]]; then
	echo -n "Install WordPress? y/n: "
	read install_wp
fi

if [ "$install_wp" = 'y' ]; then
	download_latest_wordpress

	echo "=== Copying files WordPress"
	# Copying WordPress files to root path
	rsync -azv --progress --exclude-from="$dir_name/.rsyncignore" "$dir_name/wordpress/"* $root
	echo "=== Copying files successfully"
fi

echo "=== Creating wp-config.php"
# Search and replace mysql settings in wp config
sed -e "s/{TABLE_PREFIX}/$prefix_table/g;s/{DB_NAME}/$db_name/g;s/{DB_USER}/$DB_USER/g;s/{DB_PASS}/$DB_PASS/g;s/{SITE_URL}/$site/g" $dir_name/$WP_CONFIG_FILE > $root/$WP_CONFIG_FILE
echo "=== Successfully created wp-config.php"

echo "=== Creating htaccess"
# Copy htacess to root path
cp "$dir_name/.htaccess" "$root/.htaccess"
echo "=== Successfully created htaccess"

echo "=== Setting permissions in the directory"
# Set permissions
chown -R $perm $root
echo "=== Successfully in the permissions"

restart_server