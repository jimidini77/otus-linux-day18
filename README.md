# otus-linux-day18
Docker

# **Prerequisite**
- Host OS: Windows 10.0.19043
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.34
- Vagrant: 2.2.19

# **Содержание ДЗ**

* Создание кастомного образа `nginx` на базе `alpine`

# **Выполнение**

### Создание кастомного образа `nginx` на базе `alpine`

Установка и включение `docker`:
```
yum install -y docker
systemctl enable docker && systemctl start docker
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

# **Результаты**

Полученный в ходе работы `Vagrantfile`, внешний скрипт `init.sh` для shell provisioner, `Dockerfile` и конфигурационные файлы для nginx
 помещены в публичный репозиторий, образ nginx загружен в DockerHub:

- **GitHub** - https://github.com/jimidini77/otus-linux-day18
- **DockerHub** - https://hub.docker.com/repository/docker/jimidini/otus-linux-day18/