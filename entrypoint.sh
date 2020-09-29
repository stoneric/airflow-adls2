#!/usr/bin/env bash

#airflow initdb
#airflow scheduler > sch_start.log &
#airflow webserver > web_start.log 


start_standalone() {
  if test -f "$LOCAL_DB_FILE"; then
    echo "Local database already exists. $LOCAL_DB_FILE"
  else 
    echo "Creating local databsae"
    airflow initdb
    if [ $? -ne 0 ]; then
      exit 1
    fi
  fi
  airflow scheduler > sch_start.log &  
  airflow webserver > web_start.log
}


case "$1" in 
   standalone)
      start_standalone
      ;;

   bash)
      bash
      ;;

   *) airflow $1
      ;;
esac
