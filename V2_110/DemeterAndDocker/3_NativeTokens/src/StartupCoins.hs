{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings  #-}

module StartupCoins where

import           PlutusTx                        (BuiltinData, compile, unstableMakeIsData, makeIsDataIndexed)
import           PlutusTx.Prelude                (Bool (..),traceIfFalse, otherwise, Integer, ($), (<=), (&&), (>))
import           Plutus.V2.Ledger.Api            (CurrencySymbol, MintingPolicy, ScriptContext, mkMintingPolicyScript)
import           Plutus.V2.Ledger.Api            as PlutusV2
import           Plutus.V1.Ledger.Value          as PlutusV1
import           Plutus.V1.Ledger.Interval      (contains, to) 
import           Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent, ownCurrencySymbol)
--Serialization
import           Mappers                (wrapPolicy)
import           Serialization          (currencySymbol, writePolicyToFile,  writeDataToFile) 
import           Prelude                (IO)

-- ON-CHAIN CODE

data BothRedeemer = BothRedeemer { shareholder1 :: PubKeyHash
                                 , shareholder2 :: PubKeyHash
                                 }
unstableMakeIsData ''BothRedeemer

{-# INLINABLE startupCoins #-}
startupCoins :: PubKeyHash -> PubKeyHash -> () -> ScriptContext -> Bool
startupCoins shareholder1 shareholder2 _ sContext = traceIfFalse  "Not signed by both owners!" (signedByShareholder1 && signedByShareholder2)
    where
        signedByShareholder1 :: Bool
        signedByShareholder1 = txSignedBy info shareholder1

        signedByShareholder2 :: Bool
        signedByShareholder2 = txSignedBy info shareholder2

        info :: TxInfo
        info = scriptContextTxInfo sContext



{-# INLINABLE wrappedStartupCoinsPolicy #-}
wrappedStartupCoinsPolicy :: BuiltinData -> BuiltinData -> ()
wrappedStartupCoinsPolicy = wrapPolicy startupCoins

startupCoinsPolicy :: MintingPolicy
startupCoinsPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| wrappedStartupCoinsPolicy ||])

-- Serialised Scripts and Values 

saveStartupCoinsPolicy :: IO ()
saveStartupCoinsPolicy = writePolicyToFile "testnet/StartupCoins.plutus" startupCoinsPolicy

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

-- pkhShareholder1 = "8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0" 
-- pkhShareholder2 = "6efff2244d9f67a1a383db4a198a10c647408767cdcb0a44845ce15a" 

-- saveRedeemer  = writeDataToFile "./testnet/BothRedeemer.json" (BothRedeemer pkhShareholder1 pkhShareholder2)


saveAll :: IO ()
saveAll = do
            saveStartupCoinsPolicy
            saveUnit
            -- saveRedeemer
