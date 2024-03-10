{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.
{-# LANGUAGE DeriveAnyClass    #-}

module TypedValidators where

--PlutusTx 
import                  PlutusTx                       (compile,unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, (==), Bool (..), Integer, (&&))
import                  Plutus.V2.Ledger.Api        as PlutusV2
--Serialization
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                     (IO)

------------------------------------------------------------------------------------------
-- Primites Types
------------------------------------------------------------------------------------------

{-# INLINABLE typedDatum22 #-}
typedDatum22 :: Integer -> () -> ScriptContext -> Bool
typedDatum22 datum _ _ = traceIfFalse "Not the right datum!" (datum ==  22)

{-# INLINABLE typedRedeemer11 #-}
typedRedeemer11 ::  () -> Integer -> ScriptContext -> Bool
typedRedeemer11 _ redeemer _ = traceIfFalse "Not the right redeemer!" (redeemer ==  11)

------------------------------------------------------------------------------------------
-- Custom Types
------------------------------------------------------------------------------------------

newtype OurWonderfullDatum = OWD Integer
unstableMakeIsData ''OurWonderfullDatum

data OurWonderfullRedeemer = OWR Integer | JOKER Bool
makeIsDataIndexed ''OurWonderfullRedeemer [('OWR,0),('JOKER,1)]

{-# INLINABLE customTypedDatum22 #-}
customTypedDatum22 :: OurWonderfullDatum -> () -> ScriptContext -> Bool
customTypedDatum22 (OWD datum) _ _ = traceIfFalse "Not the right datum!" (datum ==  22)

{-# INLINABLE customTypedRedeemer11 #-}
customTypedRedeemer11 ::  () -> OurWonderfullRedeemer -> ScriptContext -> Bool
customTypedRedeemer11 _ (OWR number) _    =  traceIfFalse "Not the right redeemer!" (number ==  11)
customTypedRedeemer11 _ (JOKER boolean) _ =  traceIfFalse "The Joker sais no!" boolean


newtype SwapDatum = Price Integer
unstableMakeIsData ''SwapDatum

data Action = Cancel | Sell
unstableMakeIsData ''Action

swapDatum :: SwapDatum -> Action -> ScriptContext -> Bool
swapDatum (Price _ ) action ctx =
  case action of
    Sell -> traceIfFalse "Sell conditions not fullfilled!"  sellConditions
    Cancel -> traceIfFalse "Cancelation conditions not fullfilled" cancelConditions
    where
      sellConditions :: Bool
      sellConditions = valueGreaterThanPrice && sellerGetsValue && buyerGetsNFT && swapSCgetsDaCut

      cancelConditions :: Bool
      cancelConditions = True

      valueGreaterThanPrice = True

      sellerGetsValue = True

      buyerGetsNFT = True

      swapSCgetsDaCut = True
  
      txInfo :: TxInfo
      txInfo = scriptContextTxInfo ctx

      inputs :: [TxInInfo]
      inputs = txInfoInputs txInfo

      valueProvided :: [TxInfo] -> Value
      valueProvided = foldMap (txOutValue . txInInfoResolved) 

------------------------------------------------------------------------------------------
-- Mappers and Compiling expresions
------------------------------------------------------------------------------------------

-- for primitives types

mappedTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedDatum22 = wrapValidator customTypedDatum22

typedDatum22Val :: PlutusV2.Validator
typedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedDatum22 ||])

mappedTypedRedeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedRedeemer11 = wrapValidator typedRedeemer11

typedRedeemer11Val :: Validator
typedRedeemer11Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedRedeemer11 ||])



-- for custom types

mappedCustomTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomTypedDatum22 = wrapValidator customTypedDatum22

mappedCustomTypedRedeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomTypedRedeemer11 = wrapValidator customTypedRedeemer11

customTypedDatum22Val :: Validator
customTypedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomTypedDatum22 ||])

customTypedRedeemer11Val :: Validator
customTypedRedeemer11Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomTypedRedeemer11 ||])


mappedSwapDatum :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedSwapDatum = wrapValidator typedRedeemer11

swapDatumVal :: Validator
swapDatumVal = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedSwapDatum ||])



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveTypedDatum22 :: IO ()
saveTypedDatum22 =  writeValidatorToFile "./testnet/typedDatum22.plutus" typedDatum22Val

saveTypedRedeemer11 :: IO ()
saveTypedRedeemer11 =  writeValidatorToFile "./testnet/typedRedeemer11.plutus" typedRedeemer11Val

saveCustomTypedDatum22 :: IO ()
saveCustomTypedDatum22 =  writeValidatorToFile "./testnet/customTypedDatum22.plutus" customTypedDatum22Val

saveCustomTypedRedeemer11 :: IO ()
saveCustomTypedRedeemer11 =  writeValidatorToFile "./testnet/customTypedRedeemer11.plutus" customTypedRedeemer11Val

saveSwapDatumVal :: IO ()
saveSwapDatumVal =  writeValidatorToFile "./testnet/swapDatumVal.plutus" typedDatum22Val

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./testnet/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./testnet/value22.json" (22 :: Integer)

saveGoodDatum  :: IO ()
saveGoodDatum = writeDataToFile "./testnet/goodOWD.json" (OWD 22)

saveBadDatum  :: IO ()
saveBadDatum = writeDataToFile "./testnet/badOWD.json" (OWD 23)

savePrice50 :: IO ()
savePrice50 = writeDataToFile "./testnet/price50.json" (Price 50)

saveOWR  :: IO ()
saveOWR = writeDataToFile "./testnet/OWR.json" ()

saveGoodJOKER :: IO ()
saveGoodJOKER = writeDataToFile "./testnet/GoodJoker.json" (JOKER True)

saveBadJOKER :: IO ()
saveBadJOKER = writeDataToFile "./testnet/BadJoker.json" (JOKER False)

saveSell :: IO ()
saveSell = writeDataToFile "./testnet/sell.json" (Sell)

saveCancel :: IO ()
saveCancel = writeDataToFile "./testnet/cancel.json" (Cancel)

saveAll :: IO ()
saveAll = do
            saveTypedDatum22
            saveTypedRedeemer11
            saveCustomTypedDatum22
            saveCustomTypedRedeemer11
            saveSwapDatumVal
            saveUnit
            saveValue11
            saveValue22
            saveGoodDatum
            saveBadDatum
            saveOWR
            saveGoodJOKER
            saveBadJOKER
            

saveSwap :: IO ()
saveSwap = do
            saveSwapDatumVal
            savePrice50
            saveCancel
            saveSell
            
