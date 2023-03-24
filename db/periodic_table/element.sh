#! /bin/bash

GET_ELEMENT_INFO () {

  # select query to get the basic element info.
  if [[ $SELECT_ARG =~ ^[0-9]+$ ]] 
  then

    ELEMENT_SELECT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number = $SELECT_ARG")

  elif [[ ${#SELECT_ARG} -le 2 ]]
  then

    ELEMENT_SELECT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol = '$SELECT_ARG'")

  else

    ELEMENT_SELECT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name = '$SELECT_ARG'")

  fi

  # Get the rest of the element information.
  if [[ ! -z $ELEMENT_SELECT_RESULT ]] 
  then

    IFS="|"
    read ATOMIC_NUMBER SYMBOL NAME <<< $ELEMENT_SELECT_RESULT

    #The IFS needs to be set back to a space. Otherwise it interferes with the $PSQL query.
    IFS=" " 

    ELEMENT_INFO_SELECT_RESULT=$($PSQL "SELECT atomic_mass, type, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")

    IFS="|"
    read ATOMIC_MASS ELEMENT_TYPE MELTING_POINT BOILING_POINT <<< $ELEMENT_INFO_SELECT_RESULT

    #The IFS needs to be set back to a space. Otherwise it interferes with the $PSQL query.
    IFS=" " 

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  else

    echo "I could not find that element in the database."

  fi

} 

#
# This is where the code begins to run.
#

if [ -z $1 ] 
then

  echo "Please provide an element as an argument."

else
  
  SELECT_ARG=$1
  
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
  GET_ELEMENT_INFO
fi
