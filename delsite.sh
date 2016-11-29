#!/bin/bash
#!/bin/sed -f

dir_name=$(dirname $0)

source "$dir_name/helpers/utils.sh"
source "$dir_name/functions.sh"

# Importing variable of configurations.
importing_variables $dir_name

# Setings default variables
set_defaults_variables $1 $2

TEMPORARY_FILE_VHOSTS="$dir_name/vhosts.conf"
TEMPORARY_FILE_HOSTS="$dir_name/hosts"
HOSTS_FILE="/etc/hosts"

# Verifying necessary params
verifying_params $site $db_name

# Check directory exists
dir_not_exists "Is directory this project not found."

# Database not exists exit
database_not_exists $db_name

echo -n "Are you sure you want to remove the project? [y/n]: "
read is_remove_project

if [ "$is_remove_project" != 'y' ]; then
	exit_proccess "Aborted"
fi

echo "=== Creating temporary files vhosts and hosts"
touch $TEMPORARY_FILE_VHOSTS
touch $TEMPORARY_FILE_HOSTS
echo "[Done]"

echo "=== Removing virtual host"
sudo su -c\
"php -r \"echo preg_replace( '/\n# BEGIN $site(\n.*)+# END $site/', '', file_get_contents( '$VHOSTS_FILE' ) );\"\ > $TEMPORARY_FILE_VHOSTS"
echo "[Done]"

echo "=== Removing website in hosts"
sudo su -c\
"sed -e \"s/$IP $site www.$site//g;/^$/d\" $HOSTS_FILE > $TEMPORARY_FILE_HOSTS"
echo "[Done]"

echo "=== Copying new virtual host file"
sudo cp -rf $TEMPORARY_FILE_VHOSTS $VHOSTS_FILE
echo "[Done]"

echo "=== Copying new hosts file"
sudo cp -rf $TEMPORARY_FILE_HOSTS $HOSTS_FILE
echo "[Done]"

echo "=== Removing temporary files vhosts and hosts"
rm $TEMPORARY_FILE_VHOSTS
rm $TEMPORARY_FILE_HOSTS
echo "[Done]"

echo "=== Removing directory $root"
rm -rf $root
echo "[Done]"

echo "=== Deleting database $db_name"
echo "DROP DATABASE IF EXISTS $db_name;" | mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST"
echo "[Done]"

restart_server

echo "=== Project successfully removed"