#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done

while true
do
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  else
    break
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'), $(echo $CUSTOMER_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')?"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES(
  (SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'),
  $SERVICE_ID_SELECTED,
  '$SERVICE_TIME'
)")

echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') at $(echo $SERVICE_TIME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'), $(echo $CUSTOMER_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')."