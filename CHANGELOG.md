# Version 1.3.2
- module: Remove laravel module and it si added as framework into php-nginx-mysql module.
- fix: Set correct name of rails image for ruby-on-rails module.
- core: Remove default.environments.yaml of modules an create a template for all modules.
- core: Add support for multivhost.
- core: Delete script for remove alpha jefe version.
- core: Use DIR var for root dir of jefe-cli bash script
# Version 1.3.1
- module: Fix error do not up nginx to restart proyect for laravel and php-nginx-mysql module.
- module: Fix do not working commands ps, restart, logs
- core: Remove start command
- core: Set detached mode as only option in up command
- core: Add option ruby on rails in selected option
# Version 1.3.0
- module: Add select containers in itbash command for laravel module.
- fix: Fix error do not found host in nginx by laravel module.
- module: Add Ruby On Rails module.
- module: Add Laravel module.
- module: Dynamically establish the name of container services.
- module: Active mod_rewrite to php-apache-mysql image.
# Version 1.2.0
- module: Add PHP-Apache-MySQL module.
- fix: Set correct container name of mysql to php-mysql-nginx module.
# Version 1.1.0
- fix: Add usage to resetdb command in wordpress module.
- module: Add PHP-Nginx-MySQL module.
- fix: Change development environment to master into install.sh file.
# Version 1.0.0
- Initial Release.
