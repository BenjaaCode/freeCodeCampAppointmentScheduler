#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"


GET_SERVICES() {
  LIST_OF_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$LIST_OF_SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  ONCHOSEN  
}

ONCHOSEN() {
  echo -e "\nEnter a service_id"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-3]+$ ]]
  then
  # send to main menu
    GET_SERVICES
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    SEARCH_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone ='$CUSTOMER_PHONE'")
    if [[ -z $SEARCH_PHONE ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      USER_INSERTING=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        USER_INSERTING=$($PSQL "INSERT INTO customers(name) VALUES('$CUSTOMER_NAME') WHERE phone = '$CUSTOMER_PHONE'")
      fi
    fi

    echo -e "\nWhat time do you want the service?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    INSERT_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

GET_SERVICES
