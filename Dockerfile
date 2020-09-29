FROM python:3.7


ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.12
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}


RUN apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        apt-utils \
        freetds-bin \
        build-essential \
        apt-utils \
        curl \
        rsync \
        locales \
        vim \
        libsasl2-dev \
        python-dev \
        libldap2-dev \ 
        libssl-dev \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install psycopg2 \
    && pip install flower \
    && pip install pyldap \
    && pip install ldap3 \
    && pip install apache-airflow[crypto,celery,redis,postgres,hive,jdbc,ldap,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip uninstall -y SQLAlchemy \
    && pip install SQLAlchemy==1.3.15 \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

ENV LOCAL_DB_FILE=$AIRFLOW_USER_HOME/airflow.db

ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=sqlite:///$LOCAL_DB_FILE

ADD airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg
ADD entrypoint.sh ${AIRFLOW_USER_HOME}/entrypoint.sh
ADD ./ldap_ca.crt /etc/ca/ldap_ca.crt
ADD webserver_config.py ${AIRFLOW_USER_HOME}/webserver_config.py

RUN chown -R airflow: ${AIRFLOW_USER_HOME}

EXPOSE 8083

USER airflow

RUN chmod +x ${AIRFLOW_USER_HOME}/entrypoint.sh

WORKDIR ${AIRFLOW_USER_HOME}

ENTRYPOINT [ "./entrypoint.sh" ]

