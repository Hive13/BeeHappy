# BeeHappy (aka BHAPI)

## Background and setup

This application is delivered as a Docker service stack with PostgreSQL and the BeeHappy Python application.
There is a Dockerfile included that builds the BHAPI application, which runs well under Alpine Linux. 

## Application stack

BeeHappy is delivered as a Docker Compose stack. The open-source Docker Engine is sufficient to run this application on either x86_64 (Intel/AMD) or aarch64 (ARM-based) platforms. It does, however, require the Compose V2 plugin which is invoked by way of `docker compose` rather than `docker-compose` (note the presence or absence of a `-` character in the command). It has not been tested on Compose V1.

### Container names and purposes
* `postgresql`: PostgreSQL 16 database server with PL/Python3 running on Debian 13
* `valkey`: Valkey (Redis-compatible key/value store) to hold server-side session data
* `app`: The BHAPI application running on Alpine Linux
* `web`: Nginx reverse proxy running on Alpine Linux

### Docker named volumes
* `pg-data`: PostgreSQL data store
* `pg-backups`: Backups and snapshots of PostgreSQL database
* `valkey-data`: Persistent data for Valkey server

### Backend
The BeeHappy backend is written entirely in [Python](https://www.python.org/) against version 3.11 or later. Python is actively maintained by the Python Software Foundation (PSF) and was first released in 1991. It is available under the permissive PSF License without any licensing fees. The Python programming language enjoys wide use in commerce, government, and academia *(it consistently ranks at or very near the top of the [TIOBE index](https://www.tiobe.com/tiobe-index/))* and has been [recommended for use by United States and international cybersecurity officials](https://www.nsa.gov/Press-Room/Press-Releases-Statements/Press-Release-View/Article/3608324/us-and-international-partners-issue-recommendations-to-secure-software-products/) due to its memory-safe design. 

BeeHappy uses the [Flask](https://flask.palletsprojects.org/) micro framework to implement the application backend. Unlike other programming languages frequently used for this purpose like PHP, Perl, or ASP.NET -- where the application code is typically placed in a standard web server's document root and lives interleaved within frontend HTML and/or JavaScript, depending on an external interpreter and potentially exposing the application's source code to the open internet -- Python with Flask is the opposite (the application code is executed as its own process rather than interpreted within another process). Flask applications implement the Web Server Gateway Interface (WSGI) and are run using a dedicated WSGI server (bhapi uses [Gunicorn](https://www.gunicorn.org/)). WSGI servers are typically very lightweight and do not have a lot of extra features, so a more traditional web server like Apache, Nginx, or IIS is used as a reverse proxy in front of the WSGI server.

## Required setup steps

The application stack needs the following files setup to function:

* `secrets/bhapi_config.py`: defining SQLALCHEMY_DATABASE_URI and CLIENT_SECRET
* `secrets/dba-password`: with desired password for pgAdmin4 superuser set up in `env/pgadmin-override.env` (NO TRAILING NEWLINE)
* `env/bhapi-override.env`: copy of `env/bhapi-default.env` with values filled

Once these application settings are in place, run the following command to 
build the application stack:

* `sudo docker compose create`

## Updating the app
The running version of the app container can be updated independently of the rest of the app stack. To update the app container, ensure the Git repository on the server is up to date, then run the following command:

* `sudo docker compose up -d --build --no-deps app`

If any other containers in the service stack have been changed during the development cycle, add their names to the end of the command after `app`.