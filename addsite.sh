#!/bin/bash

dir_name=$(dirname $0)

CONFIG_FILE="$dir_name/config.conf"

site="$1"
db_name="$2"
prefix_table="wp_"
sr_url="n"
is_replace="n"
is_clone="n"
install_wp="n"
git_url=""
is_import_db="n"
file_sql=""

if [ ! -f $CONFIG_FILE ]; then
	source $dir_name/config-sample.conf
fi

if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

if [ ! $site ]; then
	echo -n "Enter your site, example mysite.com: "
	read site
fi

if [ ! $db_name ]; then
	echo -n "Enter your database name: "
	read db_name
fi

root="$HTTP_PATH/$site"

if [ -d $root ]; then
	echo "=== Could not create the project because it already exists."
	exit
fi

echo -n "Import database? y/n: "
read is_import_db

if [ $is_import_db = 'y' ]; then

	echo -n "Inform absolute path to file .sql: "
	read file_sql

	if [ ! -f $file_sql ]; then
		echo "File not found."
		exit
	fi

	echo -n "Replace url WordPress db? y/n: "
	read is_replace
fi

if [ $is_replace = 'y' ]; then
	echo -n "Inform url to search: "
	read url_search
fi

echo -n "Clone project from git? y/n: "
read is_clone

if [ $is_clone = 'y' ]; then
	echo -n "You created the ssh key in the root user to this git? y/n: "
	read is_allowed

	if [ $is_allowed != 'y' ]; then
		echo "=== Aborted"
		exit
	fi
fi

if [ $is_clone = 'y' ]; then
	echo -n "Inform your url from git: "
	read git_url

	echo "=== Clonning project"
	git clone $git_url $root
fi

if [[ ! -d $root ]] && [[ $is_clone = 'y' ]]; then
	echo "=== Could not create the project"
	exit
fi

echo "=== Writing in vhosts"
cat << EOF >> $VHOSTS_FILE
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

if [ $db_name ]; then
	echo "=== Creating database"
    echo "CREATE DATABASE IF NOT EXISTS $db_name;" | mysql -u$DB_USER -p$DB_PASS -h$DB_HOST
    echo "=== Successfully created database"
fi

if [ $is_import_db = 'y' ]; then
	echo "=== Importing database"
	mysql -u$DB_USER -p$DB_PASS -h$DB_HOST $db_name < $file_sql
	echo "=== Successfully importing database"

	echo -n "Inform prefix your tables: "
	read prefix_table
fi

if [[ $is_replace = 'y' ]] && [[ $is_import_db = 'y' ]]; then
	echo "=== Init replace database"
	$dir_name/srdb.cli.php -h$DB_HOST -u$DB_USER -p$DB_PASS -n$db_name -s "$url_search" -r "$site"
	echo "=== Replace database successful"
fi

if [ ! -d $root ]; then
	echo "=== Creating directory root"
	mkdir $root
	echo "=== Successfully created directory root"
fi

if [ $is_clone != 'y' ]; then
	echo -n "Install WordPress? y/n: "
	read install_wp
fi

if [ $install_wp = 'y' ]; then
	if [[ $WP_VERSION != $LATEST_WP_VERSION ]] || [[ ! -d "$dir_name/wordpress" ]]; then
		# Remove old directory wordpress
		rm -rf "$dir_name/wordpress"

		# Download latest version WordPress
		wget -O $dir_name/$LATEST_FILE $WP_LATEST

		# Extract zip WordPress
		unzip $dir_name/$LATEST_FILE -d $dir_name

		# Remove file latest.zip
		rm -rf $dir_name/$LATEST_FILE
	fi

	echo "=== Copying files WordPress"
	# Copying WordPress files to root path
	rsync -azv --progress --exclude-from="$dir_name/.rsyncignore" $dir_name/wordpress/* $root
	echo "=== Copying files successfully"
fi

echo "=== Creating wp-config.php"
# Search and replace mysql settings in wp config
sed -e "s/{TABLE_PREFIX}/$prefix_table/g;s/{DB_NAME}/$db_name/g;s/{DB_USER}/$DB_USER/g;s/{DB_PASS}/$DB_PASS/g;s/{SITE_URL}/$site/g" $dir_name/$WP_CONFIG_FILE > $root/$WP_CONFIG_FILE
echo "=== Successfully created wp-config.php"

echo "=== Creating htaccess"
# Copy htacess to root path
cp $dir_name/.htaccess $root/.htaccess
echo "=== Successfully created htaccess"

echo "=== Setting permissions in the directory"
# Set permissions
chown -R $perm $root
echo "=== Successfully in the permissions"

echo "=== Restarting server"
# Restart apache
service $SERVER restart