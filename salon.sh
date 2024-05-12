#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# Display services
DISPLAY_SERVICES() {
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo -e "\nPlease select a service."
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  # If service doesn't exist
  SELECTION_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SELECTION_RESULT ]]
  then
    DISPLAY_SERVICES "Invalid Response:"
  else
    # Request phone number
    echo -e "\nPlease enter your phone-number:"
    read CUSTOMER_PHONE

    # Search for customer
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_ID ]]
    then
      # Add new customer data for phone-numbers not found
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME
      CUSTOMER_INSERTION_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    fi

    echo -e "\nWhat time would you like your appointment?"
    read SERVICE_TIME

    APPOINTMENT_INSERTION_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME');")
    if [[ $APPOINTMENT_INSERTION_RESULT =~ 'INSERT 0 1' ]]
    then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE customer_id=$CUSTOMER_ID")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi
  fi
}

DISPLAY_SERVICES