#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_SELECT_MENU() {
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID SERVICE
    do
        echo "$SERVICE_ID) $SERVICE" | sed 's/ |//'
    done

    read SERVICE_ID_SELECTED

    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_SELECTED ]]
    then
      SERVICE_SELECT_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      echo -e "\nWhat time would you like your $(echo $SERVICE_SELECTED | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
      read SERVICE_TIME

      INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE_SELECTED | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."  
    fi
}

SERVICE_SELECT_MENU
