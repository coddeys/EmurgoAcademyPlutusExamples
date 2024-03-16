{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE OverloadedStrings   #-}

module ValidateAllorNothing where

import                  PlutusTx                    as PlutusTx
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($), (>))
import                  Plutus.V1.Ledger.Value      as PlutusV1
import                  Plutus.V1.Ledger.Interval   as Interval
import                  Plutus.V2.Ledger.Api        as PlutusV2
import                  Plutus.V2.Ledger.Contexts   as Contexts
import                  Mappers                     as Mapers
import                  Serialization               as Serialization
import                  Prelude                     (IO, putStrLn) 

data ConditionsDatum = Conditions { owner :: PubKeyHash
                                  , timelimit :: POSIXTime
                                  , price :: Integer
                                  }
unstableMakeIsData ''ConditionsDatum

data ActionsRedeemer = Owner | Time | Price
unstableMakeIsData '' ActionsRedeemer

main :: IO ()
main = 
  putStrLn "Hello "

