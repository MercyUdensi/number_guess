#!/bin/bash

# Set up PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_INFO=$($PSQL "SELECT user_id, username FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]; then
  # New user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Returning user
  USER_ID=$(echo $USER_INFO | cut -d '|' -f 1)
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate secret number
SECRET_NUMBER=$((1 + RANDOM % 1000))
# echo "DEBUG: $SECRET_NUMBER"  # Uncomment this to cheat 😂

# Initialize guess count
GUESS_COUNT=0
echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS

  # Check if it's an integer
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Valid guess, increase count
  ((GUESS_COUNT++))

  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

# Insert game result
if [[ -z $USER_ID ]]; then
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
fi
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")

# Success message
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
