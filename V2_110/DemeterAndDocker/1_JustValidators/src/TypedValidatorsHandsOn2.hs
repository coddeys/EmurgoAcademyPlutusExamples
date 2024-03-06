{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module TypedValidatorsHandsOn2 where

--PlutusTx
import                  PlutusTx                       (BuiltinData, compile,unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, traceError, otherwise, (==), Bool (..), Integer, ($))
import                  Plutus.V2.Ledger.Api        as PlutusV2
--Serialization
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                     (IO)

------------------------------------------------------------------------------------------
-- Custom Types
------------------------------------------------------------------------------------------

data OurWonderfullDatum = OWDI Integer | OWDB Bool
makeIsDataIndexed ''OurWonderfullDatum [('OWDI,0),('OWDB,1)]

data OurWonderfullRedeemer = OWRI Integer | OWRB Bool | JOKER
makeIsDataIndexed ''OurWonderfullRedeemer [('OWRI,0),('OWRB,1),('JOKER,2)]

{-# INLINABLE customDatumEqRedeemer #-}
customDatumEqRedeemer :: OurWonderfullDatum -> OurWonderfullRedeemer -> ScriptContext -> Bool
customDatumEqRedeemer  _         JOKER    _ = True 
customDatumEqRedeemer  _        (OWRB rb) _ = traceIfFalse "Boolean is FALSE!" rb
customDatumEqRedeemer (OWDI dn) (OWRI rn) _ = traceIfFalse "Number are not eq!" (dn ==  rn)
customDatumEqRedeemer  _         _        _ = traceError   "Not the right redeemer!" False

------------------------------------------------------------------------------------------
-- Mappers and Compiling expresions
------------------------------------------------------------------------------------------

mappedCustomDatumEqRedeemer :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomDatumEqRedeemer = wrapValidator customDatumEqRedeemer 

customDatumEqRedeemerValidator :: Validator
customDatumEqRedeemerValidator = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomDatumEqRedeemer ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveCustomDatumEqRedeemerValidator :: IO ()
saveCustomDatumEqRedeemerValidator =  writeValidatorToFile "./testnet/typedDatumEqRedeemerValidator.plutus" customDatumEqRedeemerValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

saveOWDIValue33 :: IO ()
saveOWDIValue33 = writeDataToFile "./testnet/owdi33.json" (OWDI 33)

saveOWDRValue33 :: IO ()
saveOWDRValue33 = writeDataToFile "./testnet/owri33.json" (OWRI 33)

saveOWDBTrue :: IO ()
saveOWDBTrue = writeDataToFile "./testnet/owdbTrue.json" (OWDB True) 

saveOWDRTrue :: IO ()
saveOWDRTrue = writeDataToFile "./testnet/owdrTrue.json" (OWRB True)

saveOWDBFalse :: IO ()
saveOWDBFalse = writeDataToFile "./testnet/owdbFalse.json" (OWDB False)

saveOWDRFalse :: IO ()
saveOWDRFalse = writeDataToFile "./testnet/owdrFalse.json" (OWRB False)

saveJOKER :: IO ()
saveJOKER = writeDataToFile "./testnet/joker.json" (JOKER)

saveAll :: IO ()
saveAll = do
  saveCustomDatumEqRedeemerValidator
  saveUnit
  saveOWDIValue33
  saveOWDRValue33
  saveOWDBTrue
  saveOWDRTrue
  saveOWDBFalse
  saveOWDRFalse
  saveJOKER

