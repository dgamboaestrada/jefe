# Version x.x.x
- core: Fix verbose of deploy command

# Version 1.5.0
- module-pam: Add frameworks support to php-apache-mysql module
- moduel-pnm: Add Cakephp2.x framework support for php-nginx-mysql module
- module-wordpress: Add php-extensions-install command for wordpress module
- module-pam: Fix itbash command for php-apache-mysql module
- core: Add proxy settings template for jefe-nginx-proxy
# Version 1.4.0
- module-wordpress: Remove phpmyadmin from wordpress module
- core: Fix error to remove vhost in operating systems based on unix
- core: Fix error to remove vhost in operating systems based on unix
- module-wordpress: Add debug command for wordpress module
- module-pam: Remove phpmyadmin from php apache mysql module
# Version 1.3.8
- module-wordpress: Add compatibility with circle for deploy command of wordpress module
- module-wordpress: Remove phpmyadmin from wordpress module
- core: Fix error to remove vhost in operating systems based on unix
- core: Fix error to remove vhost in operating systems based on unix
# Version 1.3.7
- core: Set default value of DIR constant with ~/.jefe-cli
# Version 1.3.6
- module-wordpress: Fix deploy of wordpress module
# Version 1.3.5
- core: Refactorice loaders script to import other scripts in services and libraries
- core: Refactorice itbash command
- module-wordpress: Refactorice deploy command and add after_up tringer for wordpress module
# Version 1.3.4
- module-rails: Add itbash command with menu iterative to rails module
- module-pnm: Remove phpmyadmin container from php-nginx-mysql module
- core: Add after and before triggers for up command
- module-pnm: Add Symfony framework suport for php-nginx-mysql module
- core: Remove update_module command
- core: Fix error to execute update command in branch not equals to master
# Version 1.3.3
- module-rails: Fix command import_dump
- module-rails: Fix command dump
- module-wordpress: Remove templates of wordpress module
- service: Create estructure for services
- service: Add adminer service
- module-pnm: Fix import dump and export dump commands for php-nginx-mysql module
- module-pnm: Add rubocop command to rails module
- core: Add logs argument in up command
# Version 1.3.2
- module-pnm: Remove laravel module and it si added as framework into php-nginx-mysql module.
- fix: Set correct name of rails image for ruby-on-rails module.
- core: Remove default.environments.yaml of modules an create a template for all modules.
- core: Add support for multivhost.
- core: Delete script for remove alpha jefe version.
- core: Use DIR constant for dir path of the jefe-cli bash script
- core: Use PROJECT_DIR constant for dir path of the jefe proyect
- fix: Validate if www-data user exist when assigning permissions
- docs: Add documentations of the task stop_nginx_proxy and start_nginx_proxy
- core: Remove build task
# Version 1.3.1
- module-pnm: Fix error do not up nginx to restart proyect for laravel and php-nginx-mysql module.
- module: Fix do not working commands ps, restart, logs
- core: Remove start command
- core: Set detached mode as only option in up command
- core: Add option ruby on rails in selected option
# Version 1.3.0
- module-laravel: Add select containers in itbash command for laravel module.
- fix: Fix error do not found host in nginx by laravel module.
- module-rails: Add Ruby On Rails module.
- module-laravel: Add Laravel module.
- module: Dynamically establish the name of container services.
- module-pam: Active mod_rewrite to php-apache-mysql image.
# Version 1.2.0
- module-pam: Add PHP-Apache-MySQL module.
- fix: Set correct container name of mysql to php-mysql-nginx module.
# Version 1.1.0
- fix: Add usage to resetdb command in wordpress module.
- module-pnm: Add PHP-Nginx-MySQL module.
- fix: Change development environment to master into install.sh file.
# Version 1.0.0
- Initial Release.
