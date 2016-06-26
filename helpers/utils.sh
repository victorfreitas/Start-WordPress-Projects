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
#       Notice for SSH root user
# ======================================
function notice_for_ssh_git()
{
	echo -n "You created the ssh key in the root user to this git? [y/n]: "
	read is_allowed

	if [ $is_allowed != 'y' ]; then
		exit_proccess "Aborted"
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
	if [ -d "$1" ]; then
		exit_proccess $2
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
#   Checking database exists and die
# ======================================
function database_exists()
{
	DB_EXISTS=`echo "SHOW DATABASES LIKE '$1'" | mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" | sed -r "s/(^[a-zA-Z0-9]+)?[($1)]+//g"`

	if [ "$DB_EXISTS" ]; then
	    exit_proccess "Database $1 exists, aborting process."
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
	service "$SERVER" restart
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