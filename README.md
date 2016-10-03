# What is SuiteCRM?

> SuiteCRM is a completely open source enterprise-grade Customer Relationship Management (CRM) application. SuiteCRM is a software fork of the popular customer relationship management (CRM) system SugarCRM.

https://www.suitecrm.com/

# Prerequisites

To run this application you need Docker Engine 1.10.0. Docker Compose is recommended with a version 1.6.0 or later.

# How to use this image

## Run SuiteCRM with a Database Container

Running SuiteCRM with a database server is the recommended way. You can either use docker-compose or run the container manually.

### Run the application using Docker Compose

This is the recommended way to run SuiteCRM. You can use the following docker compose template:

```
version: '2'

services:
  mariadb:
    image: 'bitnami/mariadb:latest'
    volumes:
      - 'mariadb_data:/bitnami/mariadb'
  application:
    image: 'bitnami/suitecrm:latest'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - 'suitecrm_data:/bitnami/suitecrm'
      - 'php_data:/bitnami/php'
      - 'apache_data:/bitnami/apache'
    depends_on:
      - mariadb

volumes:
  mariadb_data:
    driver: local
  suitecrm_data:
    driver: local
  apache_data:
    driver: local
  php_data:
    driver: local
```

### Run the application manually

If you want to run the application manually instead of using docker-compose, these are the basic steps you need to run:

1. Create a new network for the application and the database:

  ```
  $ docker network create suitecrm_network
  ```

2. Start a MariaDB database in the network generated:

  ```
   $ docker run -d --name mariadb --net=suitecrm_network bitnami/mariadb
  ```

  *Note:* You need to give the container a name in order to SuiteCRM to resolve the host

3. Run the SuiteCRM container:

  ```
  $ docker run -d -p 80:80 --name suitecrm --net=suitecrm_network bitnami/suitecrm
  ```

Then you can access your application at http://your-ip/

## Persisting your application

If you remove every container and volume all your data will be lost, and the next time you run the image the application will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed. If you are using docker-compose your data will be persistent as long as you don't remove `mariadb_data` and `application_data` data volumes. If you have run the containers manually or you want to mount the folders with persistent data in your host follow the next steps:

> **Note!** If you have already started using your application, follow the steps on [backing](#backing-up-your-application) up to pull the data from your running container down to your host.

### Mount persistent folders in the host using docker-compose

This requires a slight modification from the template previously shown:

```
version: '2'

services:
  mariadb:
    image: 'bitnami/mariadb:latest'
    volumes:
      - '/path/to/your/local/mariadb_data:/bitnami/mariadb'
  application:
    image: 'bitnami/suitecrm:latest'
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - '/path/to/your/local/suitecrm_data:/bitnami/suitecrm'
      - '/path/to/your/local/php_data:/bitnami/php'
      - '/path/to/your/local/apache_data:/bitnami/apache'
    depends_on:
      - mariadb
```

### Mount persistent folders manually

In this case you need to specify the directories to mount on the run command. The process is the same than the one previously shown:

1. If you haven't done this before, create a new network for the application and the database:

  ```
  $ docker network create suitecrm_network
  ```

2. Start a MariaDB database in the previous network:

  ```
  $ docker run -d --name mariadb -v /your/local/path/bitnami/mariadb_data:/bitnami/mariadb  --net=suitecrm_network bitnami/mariadb
  ```
   *Note:* You need to give the container a name in order to SuiteCRM to resolve the host

3. Run the SuiteCRM container:

  ```
  $ docker run -d -p 80:80 --name suitecrm -v /your/local/path/bitnami/suitecrm:/bitnami/suitecrm --net=suitecrm_network bitnami/suitecrm
  ```

# Upgrade this application

Bitnami provides up-to-date versions of MariaDB and SuiteCRM, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container. We will cover here the upgrade of the SuiteCRM container. For the MariaDB upgrade you can take a look at https://github.com/bitnami/bitnami-docker-mariadb/blob/master/README.md#upgrade-this-image

1. Get the updated images:

```
$ docker pull bitnami/suitecrm:latest
```

2. Stop your container

 * For docker-compose: `$ docker-compose stop suitecrm`
 * For manual execution: `$ docker stop suitecrm`

3. (For non-compose execution only) Create a [backup](#backing-up-your-application) if you have not mounted the suitecrm folder in the host.

4. Remove the currently running container

 * For docker-compose: `$ docker-compose rm -v suitecrm`
 * For manual execution: `$ docker rm -v suitecrm`

5. Run the new image

 * For docker-compose: `$ docker-compose start suitecrm`
 * For manual execution ([mount](#mount-persistent-folders-manually) the directories if needed): `docker run --name suitecrm bitnami/suitecrm:latest`

# Configuration
## Environment variables
 When you start the SuiteCRM image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the docker run command line. If you want to add a new environment variable:

 * For docker-compose add the variable name and value under the application section:

```
application:
  image: bitnami/suitecrm:latest
  ports:
    - 80:80
  environment:
    - SUITECRM_PASSWORD=my_password
  volumes_from:
    - application_data
```

 * For manual execution add a `-e` option with each variable and value:

```
 $ docker run -d -e SUITECRM_PASSWORD=my_password -p 80:80 --name suitecrm -v /your/local/path/bitnami/suitecrm:/bitnami/suitecrm --net=suitecrm_network bitnami/suitecrm
```

Available variables:

 - `SUITECRM_USERNAME`: SuiteCRM application username. Default: **User**
 - `SUITECRM_PASSWORD`: SuiteCRM application password. Default: **bitnami**
 - `SUITECRM_EMAIL`: SuiteCRM application email. Default: **user@example.com**
 - `SUITECRM_LASTNAME`: SuiteCRM application last name. Default: **Name**
 - `SUITECRM_HOST`: Host domain or IP.
 - `MARIADB_USER`: Root user for the MariaDB database. Default: **root**
 - `MARIADB_PASSWORD`: Root password for the MariaDB.
 - `MARIADB_HOST`: Hostname for MariaDB server. Default: **mariadb**
 - `MARIADB_PORT`: Port used by MariaDB server. Default: **3306**

### SMTP Configuration

To configure SugarCMR to send email using SMTP you can set the following environment variables:

 - `SUITECRM_SMTP_HOST`: SugarCRM SMTP host.
 - `SUITECRM_SMTP_PORT`: SugarCRM SMTP port.
 - `SUITECRM_SMTP_USER`: SugarCRM SMTP account user.
 - `SUITECRM_SMTP_PASSWORD`: SugarCRM SMTP account password.
 - `SUITECRM_SMTP_PROTOCOL`: SugarCRM SMTP protocol to use.

This would be an example of SMTP configuration using a Gmail account:

 * docker-compose:

```
  application:
    image: bitnami/suitecrm:latest
    ports:
      - 80:80
    environment:
      - SUITECRM_SMTP_HOST=smtp.gmail.com
      - SUITECRM_SMTP_USER=your_email@gmail.com
      - SUITECRM_SMTP_PASSWORD=your_password
      - SUITECRM_SMTP_PROTOCOL=TLS
      - SUITECRM_SMTP_PORT=587
```

 * For manual execution:

```
 $ docker run -d -e SUITECRM_SMTP_HOST=smtp.gmail.com -e SUITECRM_SMTP_PROTOCOL=TLS -e SUITECRM_SMTP_PORT=587 -e SUITECRM_S\
MTP_USER=your_email@gmail.com -e SUITECRM_SMTP_PASSWORD=your_password -p 80:80 --name suitecrm -v /your/local/path/bitnami/\
suitecrm:/bitnami/suitecrm bitnami/suitecrm
```

# Backing up your application

To backup your application data follow these steps:

1. Stop the running container:

* For docker-compose: `$ docker-compose stop suitecrm`
* For manual execution: `$ docker stop suitecrm`

2. Copy the SuiteCRM data folder in the host:

```
$ docker cp /your/local/path/bitnami:/bitnami/suitecrm
```

# Restoring a backup

To restore your application using backed up data simply mount the folder with SuiteCRM data in the container. See [persisting your application](#persisting-your-application) section for more info.

# Contributing

We'd love for you to contribute to this container. You can request new features by creating an
[issue](https://github.com/bitnami/bitnami-docker-suitecrm/issues), or submit a [pull request](https://github.com/bitnami/bitnami-docker-suitecrm/pulls) with your contribution.

# Issues

If you encountered a problem running this container, you can file an
[issue](https://github.com/bitnami/bitnami-docker-suitecrm/issues). For us to provide better support,
be sure to include the following information in your issue:

- Host OS and version
- Docker version (`docker version`)
- Output of `docker info`
- Version of this container (`echo $BITNAMI_APP_VERSION` inside the container)
- The command you used to run the container, and any relevant output you saw (masking any sensitive
information)

# License

Copyright 2016 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
