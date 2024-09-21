#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Keep input as argument
ARG=$1

# Determine the input type: number, symbol, or name
if [[ "$1" =~ ^[0-9]+$ ]]; then
  # Input is an atomic number
  CONDITION="elements.atomic_number = $1"
else
  # Input is a symbol or name, handle case insensitivity
  CONDITION="elements.symbol ILIKE '$1' OR elements.name ILIKE '$1'"
fi

# Fetch the element
RESULT=$($PSQL "
SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
FROM elements 
JOIN properties USING(atomic_number) 
JOIN types USING(type_id) 
WHERE $CONDITION")

if [[ -z $RESULT ]]
then
echo "I could not find that element in the database."
else
IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING_POINT BOILING_POINT <<< "$RESULT"
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi

