#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo -e "Enter your username:"
read USERNAME

#determine if previous user
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

#if not previous user, insert into database
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "insert into users(username) values('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  #if match, define/print user info
  GAMES_PLAYED=$($PSQL "select count(game_id) from games where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select min(num_guesses) from games where user_id=$USER_ID")

  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#define secret_number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

COMPARISON() {
  #input guess
  read GUESS

  #if input not a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    #send back to input
    echo -e "That is not an integer, guess again:"
    COMPARISON
  
  #if input is a match
  elif [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    #insert guess
    INSERT_MATCH=$($PSQL "insert into guesses(game_id,high_low_match) values($GAME_ID,'match')")

    #define variables
    NUM_GUESSES=$($PSQL "SELECT count(guess_id) from guesses where game_id=$GAME_ID")

    #insert game
    INSERT_GUESSES=$($PSQL "UPDATE games set num_guesses = $NUM_GUESSES where game_id = $GAME_ID")

    #message
    echo -e "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  
  #if input is lower than secret number
  elif (( $GUESS > $SECRET_NUMBER ))
  then
    #insert guess
    INSERT_LOW=$($PSQL "INSERT INTO guesses(game_id,high_low_match) VALUES($GAME_ID,'low')")

    #message
    echo -e "It's lower than that, guess again:"
    COMPARISON

  #if input is higher than secret number
  else
    #insert guess
    INSERT_HIGH=$($PSQL "INSERT INTO guesses(game_id,high_low_match) VALUES($GAME_ID,'high')")

    #message
    echo -e "It's higher than that, guess again:"
    COMPARISON
  fi
}

#insert into games
START_GAME_INSERT=$($PSQL "insert into games(user_id,secret_number) values($USER_ID,$SECRET_NUMBER)")
GAME_ID=$($PSQL "select max(game_id) from games")

#first input
echo -e "Guess the secret number between 1 and 1000:"
COMPARISON