{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE OverloadedStrings   #-}

{- 1. Create a new module with a  new validator to Validate_All_or_Nothing  (name at your discretion) -}
module ValidateAllorNothing where

import                  PlutusTx                       (BuiltinData, unstableMakeIsData, compile)
import                  PlutusTx.Prelude               (Integer, Bool (..), (&&), ($), (>), (*))
import                  Plutus.V1.Ledger.Value         (AssetClass (..), assetClassValueOf, adaSymbol, adaToken) 
import                  Plutus.V1.Ledger.Interval      (contains, to)
import                  Plutus.V2.Ledger.Api           (POSIXTime, PubKeyHash, ScriptContext, TxInfo, scriptContextTxInfo, txInfoValidRange, Validator, mkValidatorScript)
import                  Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent)
import                  Mappers                        (wrapValidator)
import                  Prelude                     (IO, putStrLn) 

data ConditionsDatum = Conditions { owner :: PubKeyHash
                                  , timelimit :: POSIXTime
                                  , price :: Integer
                                  }
unstableMakeIsData ''ConditionsDatum

data ActionsRedeemer = ActionsRedeemer ()
unstableMakeIsData '' ActionsRedeemer

{- 
2. Change the logic to the following:
   * User signature AND
   * Tx execution BEFORE timeline AND
   * Value provided must be *at least* 2 times the price.
-}
{-# INLINABLE conditionator #-}
conditionator :: ConditionsDatum -> ActionsRedeemer -> ScriptContext -> Bool
conditionator datum _ sContext =
  signedByOwner && timeLimitNotReached && priceIsAtLeast2times

  where
    info :: TxInfo
    info = scriptContextTxInfo sContext

    signedByOwner :: Bool
    signedByOwner = txSignedBy info $ owner datum

    timeLimitNotReached :: Bool
    timeLimitNotReached = contains (to $ timelimit datum) $ txInfoValidRange info 
    priceIsAtLeast2times :: Bool
    priceIsAtLeast2times =  assetClassValueOf (valueSpent info)  (AssetClass (adaSymbol, adaToken)) > price datum * 2


mappedCommonConditions :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCommonConditions = wrapValidator conditionator

conditionsValidator :: Validator
conditionsValidator =  mkValidatorScript $$(compile [|| mappedCommonConditions ||])

{-
3. Serialize the contract, and the following values:
   1. datum with your selected wallet pubkeyhash, timeline and price. (you select them, this are arbitrary conditions)
   2. Feel free to create several with different values.
-}

main :: IO ()
main = 
  putStrLn "Hello "

