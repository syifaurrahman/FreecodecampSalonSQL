#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"
echo

while true; do
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
  read SERVICE_ID_SELECTED

  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  else
    SERVICE_NAME=""
  fi

  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  echo
  echo "I could not find that service. What would you like today?"
done

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

PHONE_ESC=$(printf "%s" "$CUSTOMER_PHONE" | sed "s/'/''/g")

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$PHONE_ESC';")

if [[ -z "$CUSTOMER_NAME" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  NAME_ESC=$(printf "%s" "$CUSTOMER_NAME" | sed "s/'/''/g")
  $PSQL "INSERT INTO customers(phone, name) VALUES ('$PHONE_ESC', '$NAME_ESC');" >/dev/null
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_ESC';")

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

TIME_ESC=$(printf "%s" "$SERVICE_TIME" | sed "s/'/''/g")
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$TIME_ESC');" >/dev/null

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."