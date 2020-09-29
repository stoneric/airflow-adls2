import os
from airflow import configuration as conf
from flask_appbuilder.security.manager import AUTH_LDAP
basedir = os.path.abspath(os.path.dirname(__file__))

SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')

CSRF_ENABLED = True

AUTH_TYPE = AUTH_LDAP

AUTH_ROLE_ADMIN = 'Admin'
AUTH_USER_REGISTRATION = True

AUTH_USER_REGISTRATION_ROLE = "Admin"
# AUTH_USER_REGISTRATION_ROLE = "Viewer"

AUTH_LDAP_SERVER = 'ldaps://ldaps.YOURDOMAIN.com:636'
AUTH_LDAP_SEARCH = "DC=YOURDOMAIN,DC=com"
AUTH_LDAP_BIND_USER = os.environ.get('AUTH_LDAP_BIND_USER')
AUTH_LDAP_BIND_PASSWORD = os.environ.get('AUTH_LDAP_BIND_PASSWORD')
AUTH_LDAP_UID_FIELD = 'sAMAccountName'
AUTH_LDAP_USE_TLS = False
AUTH_LDAP_ALLOW_SELF_SIGNED = True
AUTH_LDAP_TLS_CACERTFILE = '/etc/ca/ldap_ca.crt'
