#!/bin/sh
#!/bin/bash
#!/bin/sed -f

# ======================================
#  Importing variable of configurations.
# ======================================
function importing_variables()
{
	CONFIG_FILE="$1/config.conf"

	if [ ! -f "$CONFIG_FILE" ]; then
		source "$1/config-sample.conf"
	fi

	if [ -f "$CONFIG_FILE" ]; then
		source $CONFIG_FILE
	fi
}

# ======================================
# 	    Setings default variables
# ======================================
function set_defaults_variables()
{
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
	root="$HTTP_PATH/$site"
}

# ======================================
# 	   Verifying necessary params
# ======================================
function verifying_params()
{
	if [ ! "$1" ]; then
		echo -n "Enter your site, example mysite.com: "
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
	if [[ "$WP_VERSION" != "$LATEST_WP_VERSION" ]] || [[ ! -d "$dir_name/wordpress" ]]; then
		# Remove old directory wordpress
		rm -rf "$dir_name/wordpress"

		# Download latest version WordPress
		wget -O "$dir_name/$LATEST_FILE" $WP_LATEST

		# Extract zip WordPress
		unzip "$dir_name/$LATEST_FILE" -d $dir_name

		# Remove file latest.zip
		rm -rf "$dir_name/$LATEST_FILE"
	fi
}