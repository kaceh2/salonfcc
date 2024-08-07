#Le dice al compilador que interpretador usar
#!/bin/bash
# Se guarda en la variable PSQL la conexión al terminal 
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {

  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"
  AVAILABLE_SERVICES=$($PSQL"SELECT * from services") #Guarda en la variable el resultado de la query 
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME # La salida de impresión de pantalla se ocupa para y guardar los contenidos  en las variables SERVICE_ID, BAR y SERVICE_NAME 
  do
    echo "$SERVICE_ID) $SERVICE_NAME" #Imprime las variables de acuerdo al formato
  done 
  
  read SERVICE_ID_SELECTED #Guarda la opción seleccionada
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]] # Si la opción no es un numero del 1 al 5  
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE PHONE='$CUSTOMER_PHONE'") #Selecciona la id de la tabla clientes donde el numero sea el otorgado
    if [[ -z $CUSTOMER_ID ]] #Si no existe
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL"INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") # Se repite por si no se encontro anteriormente
    SERVICE_NAME=$($PSQL"SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
    CUSTOMER_NAME=$($PSQL"SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL"INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
    


}

MAIN_MENU
