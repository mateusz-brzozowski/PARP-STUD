module Rules.Look where

import Rules.Checking
import Rules.Fact
import Rules.Location
import Rules.State
import Rules.Utility

retrieveLocation :: State -> Location
retrieveLocation state =
  let locationName = currentLocation state
      location = head $ filter (\x -> name x == locationName) $ locations state
   in location

lookName :: State -> Result
lookName state =
  let location = retrieveLocation state
   in success [locationName location] state

lookDescription :: State -> Result
lookDescription state =
  let location = retrieveLocation state
   in success (locationDescription location) state

lookPeople :: State -> Result
lookPeople state =
  let location = retrieveLocation state
      people' = people location
   in success (map name people') state

lookItems :: State -> Result
lookItems state =
  let location = retrieveLocation state
      items' = items location
   in success (map name items') state

lookAround :: State -> Result
lookAround state =
  let location = retrieveLocation state
      paths' = getActivePaths state (paths location)
      stateWithSeenNorth = addFact state (Fact $ "seen_" ++ name (north paths'))
      stateWithSeenSouth = addFact stateWithSeenNorth (Fact $ "seen_" ++ name (south paths'))
      stateWithSeenEast = addFact stateWithSeenSouth (Fact $ "seen_" ++ name (east paths'))
      stateWithSeenWest = addFact stateWithSeenEast (Fact $ "seen_" ++ name (west paths'))
   in success
        [ "n: " ++ lookAtPath (north paths'),
          "s: " ++ lookAtPath (south paths'),
          "e: " ++ lookAtPath (east paths'),
          "w: " ++ lookAtPath (west paths')
        ]
        stateWithSeenWest

lookAtPath :: Path -> String
lookAtPath path =
  name path
    ++ ( case path of
           LockedPath a item -> " - you need " ++ item
           _ -> ""
       )

isPathActive :: State -> Path -> Bool
isPathActive state path =
  case path of
    Path {} -> True
    LockedPath {} -> True
    InvalidPath {} -> False
    ConditionalPath _ condition _ -> checkCondition state condition

getActivePath :: State -> Path -> Path
getActivePath state path =
  if isPathActive state path
    then case path of
      ConditionalPath activePath _ _ -> activePath
      _ -> path
    else case path of
      ConditionalPath _ _ anotherPath -> anotherPath
      _ -> InvalidPath

getActivePaths :: State -> Paths -> Paths
getActivePaths state paths =
  let northPath = getActivePath state (north paths)
      southPath = getActivePath state (south paths)
      eastPath = getActivePath state (east paths)
      westPath = getActivePath state (west paths)
   in Paths {north = northPath, south = southPath, east = eastPath, west = westPath}