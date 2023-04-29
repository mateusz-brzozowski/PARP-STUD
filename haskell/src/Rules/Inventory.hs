module Rules.Inventory where

import Rules.Colors
import Rules.Item
import Rules.Location
import Rules.Movement
import Rules.State
import Rules.Utility

takeObject :: String -> State -> Result
takeObject object state =
  let location = retrieveLocation state
      items' = filter (\x -> name x == object) $ items location
   in if null items'
        then failure ["I don't see it here."] state
        else
          if length (inventory state) >= 5
            then failure ["Your inventory is full! Drop something before picking " ++ object ++ " up!"] state
            else
              success
                ["Ok."]
                state
                  { locations = (location {items = filter (\x -> name x /= object) $ items location}) : filter (/= location) (locations state),
                    inventory = head items' : inventory state
                  }

dropObject :: String -> State -> Result
dropObject object state =
  let location = retrieveLocation state
      items' = filter (\x -> name x == object) $ inventory state
   in if null items'
        then failure ["You aren't holding it!"] state
        else
          success
            ["Ok."]
            state
              { locations = (location {items = head items' : items location}) : filter (/= location) (locations state),
                inventory = filter (\x -> name x /= object) $ inventory state
              }

listInventory :: State -> Result
listInventory state =
  let location = retrieveLocation state
   in success (applyColor colorBlue ("Inventory " ++ show (length $ inventory state) ++ "/5:") : map name (inventory state)) state
