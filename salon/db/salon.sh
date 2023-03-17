#! /bin/bash

SELECT_SERVICE() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"

  echo -e "\nWelcome to the My Salon, how can I help you?\n"

  # get services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  SERVICE_NOT_SELECTED=1

  while [[ $SERVICE_NOT_SELECTED -eq 1 ]]  
  do

    # display services
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  
    # ask for service
    echo -e "\nWhat would you like done?"
    read SERVICE_ID_SELECTED

    # verify valid service selected.    
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      echo -e "\nInvalid selection, please select a number off the menu.\n"
      continue
    fi

    SERVICE_ID_VERIFIED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_ID_VERIFIED ]]
    then
      # send to main menu
      echo -e "\nI could not find that service. Please select a service off the menu.\n"
      continue
    fi

    SERVICE_NOT_SELECTED=0;

  done
}

GET_CUSTOMER_INFO() {

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_VERIFIED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/"/')

  #get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone='$CUSTOMER_PHONE'")

  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]] 
  then
    #get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  SERVICE_TIME_FORMATTED=$(echo $SERVICE_TIME | sed 's/ |/"/')

  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."

}

MAIN_FUNCTION() {
  
  PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

  SELECT_SERVICE
  GET_CUSTOMER_INFO
}

MAIN_FUNCTION
