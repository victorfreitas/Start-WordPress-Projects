# Starting New Projects WordPress

Automation for creating new projects in WordPress to localhost with apache and virtual hosts.

  > Very useful for developers, facility for creating new projects.

# Possibilities

  * Cloning a project at the time of installation.
  * Import an existing project in directory.
  * Import an existing database.
  * Replace urls at the time of installation.
  * Create a clean install of WordPress, with only the necessary files.
  * WP Config already set.
  * htaccess already set.

### Version
1.1.0

### Installation
 Go to the project directory
```sh
$ cd Starting-New-Projects-WordPress/
```
Create in current directory, the config.conf file and alter variables of configuration. To be not overwritten in any updates.
```sh
$ cp config-sample.conf config.conf
```

Create an alias to make life easier, add at the end of file the following command.
```sh
$ echo alias addsite=\"sudo path/to/Starting-New-Projects-WordPress/addsite.sh \$1 \$2\" >> ~/.bashrc
```
```sh
$ echo alias delsite=\"sudo path/to/Starting-New-Projects-WordPress/delsite.sh \$1 \$2\" >> ~/.bashrc
```
```sh
$ source ~/.bashrc
```

After all set settings. Add command in the terminal to add new project.

```sh
$ addsite your-project.dev database_name
```

To remove a project just type the following command in the terminal.

```sh
$ delsite your-project.dev database_name
```

## Notice

- To clone a git project you must add a root key in git
