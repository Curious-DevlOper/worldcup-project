#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Truncate tables to clear any existing data (for testing purposes)
echo "Clearing existing data..."
$PSQL "TRUNCATE TABLE games, teams;"

# Read each line of the CSV, skipping the header
echo "Reading data from games.csv..."
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip header line
  if [[ $YEAR != "year" ]]
  then
    # Check if the winner team is already in the teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # If not found, insert winner team
    if [[ -z $WINNER_ID ]]
    then
      echo "Inserting team: $WINNER"
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # Get the new winner_id after insertion
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Check if the opponent team is already in the teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # If not found, insert opponent team
    if [[ -z $OPPONENT_ID ]]
    then
      echo "Inserting team: $OPPONENT"
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # Get the new opponent_id after insertion
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insert the game data into the games table
    echo "Inserting game: Year=$YEAR, Round=$ROUND, Winner=$WINNER_ID, Opponent=$OPPONENT_ID, Winner Goals=$WINNER_GOALS, Opponent Goals=$OPPONENT_GOALS"
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done

echo "Data insertion complete."