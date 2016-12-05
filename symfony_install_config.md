## Symfony

- [Install and Config](#install-and-config)
  - [Installing the Symfony Installer](#installing-the-symfony-installer)
  - [Install and enable the `intl` extension](#install-and-enable-the-`intl`-extension)
  - [Install PHP accelerator `APC`](#install-php-accelerator-`apc`)
  - [Creating the Symfony Application](#creating-the-symfony-application)
  - [Running the Symfony Application](#running-the-symfony-application)
  - [NGINX](#nginx)
  - [Updating Symfony Applications](#updating-symfony-applications)

### Install and Config

#### Installing the Symfony Installer

* Execute the following commands:

~~~
$ sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
$ sudo chmod a+x /usr/local/bin/symfony
~~~

* This will create a global `symfony` command in your system.

---

#### Install and enable the `intl` extension

* Verify that `autoconf` and `icu4c` are installed:

~~~
$ brew ls autoconf
$ brew ls icu4c
~~~

* Install `intl` using `pecl`:

~~~
$ sudo pecl install intl
~~~

* When asked for the path to the ICO libraries and headers, answer with `/usr/local/opt/icu4c`

----

#### Install PHP accelerator `APC`:

* Verify that `pcre` is installed:

~~~
$ brew ls pcre
~~~

* To disarm the `SIP`, follow these steps:
  - Reboot in recovery mode by holding `command + R`
  - Open the terminal
  - Enter the following command : `csrutil disable`
  - Restart your computer.
* Create symbolic link for `pcre.h` in `/usr/include/`:
~~~
# execute the following
$ sudo ln -s /usr/local/include/pcre.h /usr/include/
~~~

* Arm `SIP: csrutil enable`

* Install `apc` using `pecl` ([reference](https://pecl.php.net/package/APCu))
~~~
# For php56
$ sudo pecl install apcu-4.0.11
~~~

----

#### Creating the Symfony Application
* Creating a Symfony application with the new command ([reference](http://symfony.com/doc/current/setup.html#creating-the-symfony-application))
~~~
$ symfony new my_project_name
~~~

----

#### Running the Symfony Application

* Symfony leverages the internal web server provided by PHP to run applications while developing them ([reference](http://symfony.com/doc/current/setup.html#running-the-symfony-application))
~~~
$ cd my_project_name/
$ php bin/console server:run
~~~
* To see the welcome page for Symfony: `http://localhost:8000/`
* To ensure the Symfony is configured correctly: `http://localhost:8000/config.php`

----

#### NGINX

* In order develop a Symfony project utilizing a **NginX** server place the following in `/private/var/sentry/.local/etc/nginx/sites-available/default;` enable and restart NginX server.

~~~
server {

listen 80;

server_name localhost;

root /private/var/sentry/.local/var/www/first_symfony_project/web;
location / {

include /usr/local/etc/nginx/conf.d/php-fpm;

try_files $uri @pass_to_symfony;

}

location ~ /app_dev.php/ {

try_files $uri @pass_to_symfony_dev;

}

location @pass_to_symfony{
rewrite ^ /app.php?$request_uri last;

}

location @pass_to_symfony_dev{
rewrite ^ /app_dev.php?$request_uri last;

}
location = /info {

allow 127.0.0.1;

deny all;

rewrite (.*) /.info.php;

}

error_page 404 /404.html;

error_page 403 /403.html;

}
~~~

----

#### Updating Symfony Applications
* Every Symfony app depends on a number of third-party libraries stored in the vendor/ directory and managed by Composer. Updating those libraries frequently is a good practice to prevent bugs. Execute the `update` Composer command to update them all at once and security vulnerabilities.
~~~
$ cd my_project_name/
$ composer update
~~~
  * Symfony provides a command to check whether your project's dependencies contain any known security vulnerability:
~~~
$ php bin/console security:check
~~~
  * A good security practice is to execute this command regularly to be able to update or replace compromised dependencies as soon as possible.
