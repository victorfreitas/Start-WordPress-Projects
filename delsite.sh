#!/bin/bash

dir_name=$(dirname $0)

CONFIG_FILE="$dir_name/config.conf"

if [ ! -f $CONFIG_FILE ]; then
	source $dir_name/config-sample.conf
fi

if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

site="$1"
db_name="$2"
root="$HTTP_PATH/$site"
TEMPORARY_FILE_VHOSTS="$dir_name/vhosts.conf"
TEMPORARY_FILE_HOSTS="$dir_name/hosts"
HOSTS_FILE="/etc/hosts"
MESSAGE_DB="=== Database deleted successfully"

if [ ! -d $root ]; then
	echo "=== Is directory this project not found."
	exit
fi

echo -n "Are you sure you want to remove the project? y/n: "
read is_remove_project

if [ $is_remove_project != 'y' ]; then
	echo "=== Aborted"
	exit
fi

if [ ! $site ]; then
	echo -n "Enter your site, example mysite.com: "
	read site
fi

if [ ! $db_name ]; then
	echo -n "Enter your database name: "
	read db_name
fi

echo "=== Creating temporary files vhosts and hosts"
touch $TEMPORARY_FILE_VHOSTS
touch $TEMPORARY_FILE_HOSTS
echo "=== Temporary files created successfully"

echo "=== Removing virtual host"
php -r "echo preg_replace( '/\n# BEGIN $site(\n.*)+# END $site/', '', file_get_contents( '$VHOSTS_FILE' ) );"\ > $TEMPORARY_FILE_VHOSTS
echo "=== Virtual host successfully removed"

echo "=== Removing website in hosts"
sed -e "s/$IP $site www.$site//g" $HOSTS_FILE > $TEMPORARY_FILE_HOSTS
echo "=== Website in hosts successfully removed"

echo "=== Copying new virtual host file"
cp -rf $TEMPORARY_FILE_VHOSTS $VHOSTS_FILE
echo "=== New virtual host file copied successfully"

echo "=== Copying new hosts file"
cp -rf $TEMPORARY_FILE_HOSTS $HOSTS_FILE
echo "=== New hosts file copied successfully"

echo "=== Removing temporary files vhosts and hosts"
rm $TEMPORARY_FILE_VHOSTS
rm $TEMPORARY_FILE_HOSTS
echo "=== Temporary files successfully removed"

echo "=== Removing directory $root"
rm -rf $root
echo "=== Directory $root successfully removed"

echo "=== Deleting database $db_name"
echo "DROP DATABASE IF EXISTS $db_name;" | mysql -u$DB_USER -p$DB_PASS -h$DB_HOST

DB_EXISTS=`echo "SHOW DATABASES LIKE '$1'" | mysql -u$DB_USER -p$DB_PASS -h$DB_HOST | sed -r "s/(^[a-zA-Z0-9]+)?[($1)]+//g"`

if [ $DB_EXISTS ]; then
    MESSAGE_DB="=== Unable to delete the database $db_name"
fi

echo $MESSAGE_DB

echo "=== Restarting server"
service $SERVER restart

echo "=== Project successfully removed"