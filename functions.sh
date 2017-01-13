#!/bin/sh
#!/bin/bash
#!/bin/sed -f

# ======================================
# 	    Setings default variables
# ======================================
function set_defaults_variables()
{
	site="$1"
	db_name="$2"
	prefix_table="nq4g6X_"
	sr_url="n"
	is_replace="n"
	is_clone="n"
	install_wp="n"
	git_url=""
	is_import_db="n"
	file_sql=""
	root="$HTTP_PATH/$site"
	DB_TMP="db_tmp.sql"
	usr_random="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)_usr"
	WP_USER=$(id -un)
}

# ======================================
#  Importing variable of configurations.
# ======================================
function importing_variables()
{
	CONFIG_FILE="$1/config.conf"
	VERSION_FILE="$dir_name/version.conf"

	if [ ! -f "$CONFIG_FILE" ]; then
		CONFIG_FILE="$1/config-sample.conf"
	fi

	if [ ! -f "$VERSION_FILE" ]; then
		echo "CURRENT_WP_VERSION=$LATEST_WP_VERSION" > "$VERSION_FILE"
	fi

	source $CONFIG_FILE
	source $VERSION_FILE
}

# ======================================
# 	   Verifying necessary params
# ======================================
function verifying_params()
{
	if [ ! "$1" ]; then
		echo -n "Enter your domain, [example.com]: "
		read site
	fi

	if [ ! "$2" ]; then
		echo -n "Enter your database name: "
		read db_name
	fi

	check_params_is_empty $site $db_name
	root="$HTTP_PATH/$site"
}

# ======================================
#  Check and download latest wordpress
# ======================================
function download_latest_wordpress()
{
	if [[ "$LATEST_WP_VERSION" > "$CURRENT_WP_VERSION" ]] || [[ ! -d "$dir_name/wordpress" ]]; then
		# Remove old directory wordpress
		sudo rm -rf "$dir_name/wordpress"

		# Download latest version WordPress
		echo "Download latest WordPress version..."
		wget --no-verbose --output-document="$dir_name/$LATEST_FILE" $WP_LATEST

		# Extract zip WordPress
		echo "Extracting WordPress..."
		unzip -qq "$dir_name/$LATEST_FILE" -d $dir_name

		# Remove file latest.zip
		echo "Removing zip file"
		rm -rf "$dir_name/$LATEST_FILE"

		# Set global Current WP Version
		echo "CURRENT_WP_VERSION='$LATEST_WP_VERSION'" > "$dir_name/version.conf"
		echo "[Done]"
	fi
}

# ======================================
#     Check for Vhosts file exists
# ======================================
function check_vhosts_exits()
{
	if [ ! -f $VHOSTS_FILE ]; then
		echo -n "Vhosts file not exists, create new? [y/n]: "
		read is_create_new_vhosts

		create_new_vhosts_file $is_create_new_vhosts
		aborted_process $is_create_new_vhosts
	fi
}

# ======================================
#        Create new Vhots files
# ======================================
function create_new_vhosts_file()
{
	if [ $1 = 'y' ]; then
		echo "=== Creating new vhosts file"
		sudo su -c "echo 'Listen 80' > $VHOSTS_FILE"
		echo "[Done]"
	fi
}

# ======================================
#        Setting up database
# ======================================
function setting_database()
{
	if [ "$is_import_db" != 'y' ]; then
		create_file_tmp_db

		installing_database "$dir_name/$DB_TMP"
		rm -rf "$dir_name/$DB_TMP"

		echo "=== Replace url from database"
		replace_url "example.dev"
		echo "[Done]"
	fi
}

# ======================================
#         Create temporary DB
# ======================================
function create_file_tmp_db()
{
	if [ $WP_USER = "root" ]; then
		WP_USER=$usr_random
	fi

	if [ "$is_multisite" = 'y' ]; then
		db_multisite='_multisite'
	fi

	sed -e "s/{{USER}}/$WP_USER/g;s/{{COUNT_STRING_USER}}/${#WP_USER}/g;" "$dir_name/wp_db$db_multisite.sql" > "$dir_name/$DB_TMP"
}