# Airflow Docker image to connect to Azure Data Lake and Apache Spark or Databricks

## Build 
```
docker image build --tag airflow_ad:latest .
```

## Run
The Airflow container can operate in two modes: standalone and distributed

### Standalone
Standalone mode will start the container that will use local database backend based on sqlite located within the container. 
Most configuration settings will be left as default.

Example command:
```
docker run --name airflow_ad --rm -p 8083:8083 --env AUTH_LDAP_BIND_PASSWORD=<LDAP bind password> --env AUTH_LDAP_BIND_USER=<LDAP bind DN user name - user@domain>  -v <directory with SSL certificates>:/cert airflow_ad:latest standalone
```

<directory with SSL certificates> the directory with ssl certificates.
It must contain the following files:
 * https_cert.cert
 * https_cert.key

The default path and file names of certificate files can be changed via environment variables:
- AIRFLOW__WEBSERVER__WEB_SERVER_SSL_CERT=path within docker container to cerificate file
- AIRFLOW__WEBSERVER__WEB_SERVER_SSL_KEY=path within docker continer to certificate key


### Distributed
In the distributed mode airflow will use Celery and external database(PostgreSQL) and brocker (Redis). The following container instancess will be started:
* Webserver
* Scheduler
* Worker(one or more)

Before the first run initialize the database:
Create the data base *airflow* e.g.
```
CREATE DATABASE airflow;
```
Run the following command to initizlize the database:
```
docker run --name airflow_ad --env-file=env_conf --rm airflow_ad:latest initdb
```

docker-compose.yml will expect the envieronment variable to be provided as a file located in the work directory with file name env_conf.
It will contain configuration for PosgreSQL, Celery brocker and backend.
Below is the example:
```
AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://<username>:<password>@<server host name>:<port>/airflow
AIRFLOW__CELERY__BROKER_URL=rediss://:<Password/Secret Key>@<redis host name>:<port>/0?ssl_cert_reqs=optional
AIRFLOW__CELERY__RESULT_BACKEND=db+postgresql://<username>:<password>@<server host name>:<port>/airflow
AIRFLOW__CORE__EXECUTOR=CeleryExecutor
AUTH_LDAP_BIND_USER=<LDAP bind user name>
AUTH_LDAP_BIND_PASSWORD=<Password for LDAP bind user>
```
Note: The user name for PostgreSQL can contain @ e.g. user@host. In this case the user name must be encoded as user%40host
Note: The database in AIRFLOW__CORE__SQL_ALCHEMY_CONN and AIRFLOW__CELERY__RESULT_BACKEND must be created before the initial run.

docker-compose.yml will expect the following directories created in the working directory:
* ./cert - ssl certificates with  https_cert.cert, https_cert.key
* ./logs - for shared log files
* ./dags - Airflow DAG files

Use the following command to start:
```
docker-compose -f docker-compose.yml up -d --scale worker=<number of workers>
```
Stop all components:
```
docker-compose -f docker-compose.yml  down
```
