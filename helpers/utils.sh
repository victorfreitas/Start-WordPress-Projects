#!/bin/sh
#!/bin/bash
#!/bin/sed -f

# ======================================
#              Die proccess
# ======================================
function exit_proccess()
{
	echo "=== $1"
	exit 0
}

# ======================================
#        Check value is empty
# ======================================
function is_empty()
{
	if [ -z "$1" ]; then
		exit_proccess $2
	fi
}

# ======================================
#          Create directory
# ======================================
function create_directory()
{
	if [ ! -d "$1" ]; then
		mkdir $1
	fi
}

# ======================================
# 	    Checking params is empty
# ======================================
function check_params_is_empty()
{
	if [[ -z "$1" ]] || [[ -z "$2" ]]; then
		exit_proccess "Param sitename and database name is required."
	fi
}

# ======================================
#      Checking diretory exists
# ======================================
function dir_exists()
{
	if [ -d $root ]; then
		exit_proccess "$1"
	fi
}

# ======================================
#    Checking diretory not exists
# ======================================
function dir_not_exists()
{
	if [ ! -d $root ]; then
		exit_proccess "$1"
	fi
}

# ======================================
#      Checking file not exists
# ======================================
function file_not_exists()
{
	if [ ! -f "$file_sql" ]; then
		exit_proccess "File not found."
	fi
}

# ======================================
#     Show databases like DB Name
# ======================================
function set_db_output_variable()
{
	query="SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$db_name';"
	db_output=`echo "$query" | mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" | grep $db_name`
}

# ======================================
#   Checking database exists and die
# ======================================
function database_exists()
{
	set_db_output_variable

	if [ $db_output ]; then
	    exit_proccess "Database $1 exists, aborting process."
	fi
}

# ======================================
#  Checking database not exists and die
# ======================================
function database_not_exists()
{
	set_db_output_variable

	if [[ ! $db_output ]]; then
	    exit_proccess "Database $1 not exists, aborting process."
	fi
}

# ======================================
#   Check clonning project success
# ======================================
function is_clonning_not_success()
{
	if [[ ! -d "$1" ]] && [[ "$2" = 'y' ]]; then
		exit_proccess "Could not create the project."
	fi
}

# ======================================
#      Importing project existing
# ======================================
function importing_existing_project()
{
	if [ -d "$1" ]; then
		create_directory $root

		echo "=== Copying project"
		cp -rf "$1/"* "$root/"
		return
	fi

	exit_proccess "Directory not exist."
}

# ======================================
#           Restarting server
# ======================================
function restart_server()
{
	echo "=== Restarting server"
	sudo service "$SERVER" restart
	echo "[Done]"
}

# ======================================
#         Aborted proccess
# ======================================
function aborted_process()
{
	if [ $1 != 'y' ]; then
		exit_proccess "Aborted"
	fi
}

# ======================================
#      Replace Urls from database
# ======================================
function replace_url()
{
	"$dir_name/srdb.cli.php" -v false -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -n"$db_name" -s $1 -r $site
}

# ======================================
#        Installing database
# ======================================
function installing_database()
{
	echo "=== Installing database"
	mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" $db_name < $1
	echo "[Done]"
}