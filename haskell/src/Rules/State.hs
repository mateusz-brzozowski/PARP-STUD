module Rules.State where

import Rules.Item
import Rules.Location
import Story.City
import Story.House
import Story.Museum
import Story.Office
import Story.Police

data State = State
  { finish :: Bool,
    inventory :: [Item],
    currentLocation :: String,
    locations :: [Location]
  }

data Result = Result {messages :: [String], newState :: State, correct :: Bool}

success :: [String] -> State -> Result
success messages state = Result messages state True

failure :: [String] -> State -> Result
failure messages state = Result messages state False

initialState =
  State
    False
    []
    "Detective's house"
    (houseLocations ++ cityLocations ++ officeLocations ++ policeLocations ++ museumLocations)
