# otus-linux-day18
Docker

# **Prerequisite**
- Host OS: Windows 10.0.19043
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.34
- Vagrant: 2.2.19

# **Содержание ДЗ**

* Создание кастомного образа `nginx` на базе `alpine`
* Объединение образов в docker-compose

# **Выполнение**

### Создание кастомного образа `nginx` на базе `alpine`

Установка и включение `docker`:
```
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable containerd.service
systemctl enable docker.service
systemctl start containerd.service
systemctl start docker.service
```

Содержимое `Dockerfile`. Образ собирается на основе последнего образа `alpine`, 
в образ устанавливается `nginx`, выполняется настройка, в образ копируются файлы, 
указывается порт, на который будет отдаваться кастомная страница:
```
FROM alpine:latest
RUN apk -U upgrade && apk add nginx && echo "daemon off;" >> /etc/nginx/nginx.conf && mkdir -p /usr/share/nginx/html && chown -R nginx:nginx /usr/share/nginx/html
COPY index.html /usr/share/nginx/html/index.html
COPY test.conf /etc/nginx/http.d/test.conf
EXPOSE 8080
CMD [ "nginx" ]
```

Сборка образа:
```
docker build -t docker-nginx:v1 .
```

Запуск контейнера из образа `docker-nginx:v1` с пробросом портов 8080 из контейнера на 80 хостовой ОС:
```
docker run -d -p 80:8080 docker-nginx:v1
```

Информация о запущенном контейнере:
```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                  NAMES
33010c091a68        docker-nginx:v1     "nginx"             2 hours ago         Up 7 seconds        0.0.0.0:80->8080/tcp   pensive_spence
```

Состояние портов в хостовой ОС:
```
[root@otus mynginx]# ss -tnlp | grep 80
LISTEN     0      128       [::]:80                    [::]:*                   users:(("docker-proxy-cu",pid=29672,fd=4))
```

При запросе к 80 порту хостовой ОС nginx из контейнера отдаёт страницу:
```
[root@otus mynginx]# curl -a http://localhost:80
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>NGINX</title>
</head>
<body>
    Server is online
</body>
</html>
```

Загрузка созданного образа в Docker Hub:
```
[root@otus mynginx]# docker login --username jimidini
Password:
Login Succeeded
[root@otus mynginx]# docker tag docker-nginx:v1 jimidini/otus-linux-day18:nginx
[root@otus mynginx]# docker push jimidini/otus-linux-day18:nginx
The push refers to a repository [docker.io/jimidini/otus-linux-day18]
5915ee3e31c5: Pushed
8adb465b142c: Pushed
8607ed268395: Pushed
24302eb7d908: Mounted from library/alpine
nginx: digest: sha256:2e62b8da0fbec05868dcb988a3e4bd040963b0bbfceeaa2d37507054b0d8eab4 size: 1153
```

# Объединение образов в docker-compose

Установка docker-compose:
```
curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64" -o /usr/local/sbin/docker-compose
chmod +x /usr/local/sbin/docker-compose
```

Файловая структура для сборки docker-compose:
```
[root@otus compose]# tree
.
├── docker-compose.yml
├── nginx
│   ├── default.conf
│   └── Dockerfile
├── php
└── www
    └── html
        └── index.php

4 directories, 4 files
```

Содержимое `docker-pompose.yml`:
```
version: '3.9'
services:
    nginx: 
        image: nginx-custom:alpine
        build: ./nginx/
        container_name: nginx-container
        ports:
            - 81:80
        links:
            - php
        volumes:
            - ./www/html/:/var/www/html/
    php:
        image: php:fpm-alpine
        container_name: php-container
        ports:
            - 9000:9000
        volumes:
            - ./www/html/:/var/www/html/
```

Содержимое `index.php`:
```
[root@otus compose]# cat www/html/index.php
     <!DOCTYPE html>
     <head>
      <title>Test</title>
     </head>

     <body>
      <h1>PHPINFO</h1>
      <p><?php phpinfo(); ?></p>
     </body>
```

Образ nginx собирается на основе `Dockerfile`:
```
[root@otus compose]# cat nginx/Dockerfile
FROM nginx:alpine
COPY default.conf /etc/nginx/conf.d/default.conf
```

Запуск контейнеров:
```
[root@otus compose]# docker-compose up -d
[+] Running 3/3
 ⠿ Network compose_default    Created                                                                                                                   0.2s
 ⠿ Container php-container    Started                                                                                                                   0.7s
 ⠿ Container nginx-container  Started                                                                                                                   1.2s
[root@otus compose]# docker-compose ps
NAME                COMMAND                  SERVICE             STATUS              PORTS
nginx-container     "/docker-entrypoint.…"   nginx               running             0.0.0.0:81->80/tcp, :::81->80/tcp
php-container       "docker-php-entrypoi…"   php                 running             0.0.0.0:9000->9000/tcp, :::9000->9000/tcp
```

При запросе к 81 порту хостовой ОС nginx из контейнера отдаёт страницу `phpinfo`:
```
[root@otus compose]# curl -a http://localhost:81
     <head>
      <title>Test</title>
     </head>

     <body>
      <h1>PHPINFO</h1>
      <p><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<style type="text/css">
body {background-color: #fff; color: #222; font-family: sans-serif;}
pre {margin: 0; font-family: monospace;}
a:link {color: #009; text-decoration: none; background-color: #fff;}
a:hover {text-decoration: underline;}
table {border-collapse: collapse; border: 0; width: 934px; box-shadow: 1px 2px 3px #ccc;}
.center {text-align: center;}
.center table {margin: 1em auto; text-align: left;}
.center th {text-align: center !important;}
td, th {border: 1px solid #666; font-size: 75%; vertical-align: baseline; padding: 4px 5px;}
th {position: sticky; top: 0; background: inherit;}
h1 {font-size: 150%;}
h2 {font-size: 125%;}
.p {text-align: left;}
.e {background-color: #ccf; width: 300px; font-weight: bold;}
.h {background-color: #99c; font-weight: bold;}
.v {background-color: #ddd; max-width: 300px; overflow-x: auto; word-wrap: break-word;}
.v i {color: #999;}
img {float: right; border: 0;}
hr {width: 934px; background-color: #ccc; border: 0; height: 1px;}
</style>
<title>PHP 8.1.8 - phpinfo()</title><meta name="ROBOTS" content="NOINDEX,NOFOLLOW,NOARCHIVE" /></head>
<body><div class="center">
<table>
<tr class="h"><td>
<a href="http://www.php.net/"><img border="0" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHkAAABACAYAAAA+j9gsAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAD4BJREFUeNrsnXtwXFUdx8/dBGihmE21QCrQDY6oZZykon/gY5qizjgM2KQMfzFAOioOA5KEh+j4R9oZH7zT6MAMKrNphZFSQreKHRgZmspLHSCJ2Co6tBtJk7Zps7tJs5t95F5/33PvWU4293F29ybdlPzaM3df2XPv+Zzf4/zOuWc1tkjl+T0HQ3SQC6SBSlD6WKN4rusGm9F1ps/o5mPriOf8dd0YoNfi0nt4ntB1PT4zYwzQkf3kR9/sW4xtpS0CmE0SyPUFUJXFMIxZcM0jAZ4xrKMudQT7963HBF0n6EaUjkP0vI9K9OEHWqJLkNW1s8mC2WgVTwGAqWTafJzTWTKZmQuZ/k1MpAi2+eys6mpWfVaAPzcILu8EVKoCAaYFtPxrAXo8qyNwzZc7gSgzgN9Hx0Ecn3j8xr4lyHOhNrlpaJIgptM5DjCdzrJ0Jmce6bWFkOpqs0MErA4gXIBuAmY53gFmOPCcdaTXCbq+n16PPLXjewMfGcgEttECeouTpk5MplhyKsPBTiXNYyULtwIW7Cx1vlwuJyDLR9L0mQiVPb27fhA54yBbGttMpc1OWwF1cmKaH2FSF7vAjGezOZZJZ9j0dIZlMhnuRiToMO0c+N4X7oksasgEt9XS2KZCHzoem2Ixq5zpAuDTqTR14FMslZyepeEI4Ogj26n0vLj33uiigExgMWRpt+CGCsEePZqoePM738BPTaJzT7CpU0nu1yXpAXCC3VeRkCW4bfJYFZo6dmJyQTW2tvZc1nb71100 72362    0 72362    0     0  8130k      0 --:--:-- --:--:-- --:--:-- 8833k
...
```

# **Результаты**

Docker-образ (image) - стек слоёв только для чтения, на основе которого создаётся контейнер.

Docker-контейнер (container) - созданный на основе образа экземпляр приложения, добавляется rw-слой.

Контейнеры используют ядро хостовой системы. Для контейнеров ядро не собирается.

Полученный в ходе работы `Vagrantfile`, внешний скрипт `init.sh` для shell provisioner, `Dockerfile` и конфигурационные файлы для nginx
 помещены в публичный репозиторий, образ nginx загружен в DockerHub:

- **GitHub** - https://github.com/jimidini77/otus-linux-day18
- **DockerHub** - https://hub.docker.com/repository/docker/jimidini/otus-linux-day18/