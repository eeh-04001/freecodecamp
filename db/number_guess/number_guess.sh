#! /bin/bash

#This gets the users input.
GET_GUESS () {

  read GUESS_NUMBER

  #Validate the input is an interger.
  while [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS_NUMBER
  done

}

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME

NAME_SELECT_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
#echo -e "\nQuery Result: --- $NAME_SELECT_ID"

if [[ -z $NAME_SELECT_ID ]] 
then
  echo "Welcome, ${NAME}! It looks like this is your first time here."

  #Insert user information
  NAME_INSERT_RESULT=$($PSQL "INSERT INTO users (name) VALUES ('$NAME')")
  #echo "$NAME_INSERT_RESULT"

  # retrieve user id for insert into game table.
  NAME_SELECT_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")

else

  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $NAME_SELECT_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id = $NAME_SELECT_ID")
  
  echo "Welcome back, ${NAME}! You have played ${GAMES_PLAYED} games, and your best game took ${BEST_GAME} guesses."
fi

# Get random number to guess.
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
#echo -e "\nRandom: $RANDOM_NUMBER"

COUNT_GUESSES=1

echo "Guess the secret number between 1 and 1000:"
GET_GUESS

# Loop until the users guesses the number.
while [ $GUESS_NUMBER -ne $RANDOM_NUMBER ]
do

  if [[ $GUESS_NUMBER -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else 
    echo "It's higher than that, guess again:"
  fi

  GET_GUESS

  ((COUNT_GUESSES++))
  #echo -e "\n ** Number of Guesses: $COUNT_GUESSES **"

done

# Insert results of game.
GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES ($NAME_SELECT_ID, $COUNT_GUESSES)")

echo "You guessed it in ${COUNT_GUESSES} tries. The secret number was ${RANDOM_NUMBER}. Nice job!"
