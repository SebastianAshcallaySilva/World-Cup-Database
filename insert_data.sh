#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# DELETE DATA FROM TABLES
echo "$($PSQL "TRUNCATE TABLE games,teams")"

# FUNCTION: SEARCH_TEAM_ID
RET_VAL=0
SEARCH_TEAM_ID() {
  RET_VAL=$($PSQL "SELECT team_id FROM teams WHERE name='$1' ")
  if [[ -z $RET_VAL ]]
  then
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
    if [[ $INSERT_TEAM_RESULT = "INSERT 0 1" ]]
    then
      echo Inserted into teams, $1
    fi
    RET_VAL=$($PSQL "SELECT team_id FROM teams WHERE name='$1' ")
  fi
}

# Begin script for games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # If not the first column, begin piping to columns
  if [[ $YEAR != "year" ]]
  then
    # Search WINNER_ID in teams table from WINNER name
    SEARCH_TEAM_ID "$WINNER"
    W_ID=$RET_VAL
    RET_VAL=0
    # Search OPPONENT_ID in teams table from OPPONENT name
    SEARCH_TEAM_ID "$OPPONENT"
    O_ID=$RET_VAL
    RET_VAL=0
    # Enter variables into games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$W_ID,$O_ID,$W_GOALS,$O_GOALS)")
    if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
    then
      echo Inserted game: $W_ID v. $O_ID, $ROUND, $YEAR. 
    fi
  fi
done