#!/bin/bash

# Define the PSQL variable for easier querying
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Display a welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Function to display the main menu and handle service selection
MAIN_MENU() {
  
  echo -e "Services offered"
  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"

  # Prompt the user to select a service
  echo -e "Enter a number to select among the options:"

  # capture/read the input entered by the user
  read SERVICE_ID_SELECTED

  # Validate service selection 
  if [[ $SERVICE_ID_SELECTED -eq 1 ]]; then
    PROCESS_SERVICE "cut"
  elif [[ $SERVICE_ID_SELECTED -eq 2 ]]; then
    PROCESS_SERVICE "color"
  elif [[ $SERVICE_ID_SELECTED -eq 3 ]]; then
    PROCESS_SERVICE "perm"
  elif [[ $SERVICE_ID_SELECTED -eq 4 ]]; then
    PROCESS_SERVICE "style"
  elif [[ $SERVICE_ID_SELECTED -eq 5 ]]; then
    PROCESS_SERVICE "trim"
  else
    # If the input is invalid, display the menu again
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
  fi
}

# Function to handle the service process
PROCESS_SERVICE() {
  SERVICE=$1
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$SERVICE'")

  # Get customer's phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if the phone number exists in the database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # If the customer doesn't exist, get their name and add them to the database
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get the customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Ask for the service time
  echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert the appointment into the database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

  # Confirm the appointment
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Call the main menu function to start the script
MAIN_MENU
