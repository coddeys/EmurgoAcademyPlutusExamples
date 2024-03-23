{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}

module EAnft where

import qualified PlutusTx
import           PlutusTx.Prelude           (Bool (..) , Eq ((==)), any, traceIfFalse, ($), (&&))
import           Plutus.V1.Ledger.Value     (flattenValue)
import           Plutus.V2.Ledger.Api       (BuiltinData, CurrencySymbol,
                                             MintingPolicy,
                                             ScriptContext (scriptContextTxInfo),
                                             TokenName (unTokenName),
                                             TxId (TxId, getTxId),
                                             TxInInfo (txInInfoOutRef),
                                             TxInfo (txInfoInputs, txInfoMint),
                                             TxOutRef (TxOutRef, txOutRefId, txOutRefIdx),
                                             mkMintingPolicyScript)
import           Plutus.V2.Ledger.Api     as PlutusV2
import           Prelude              (IO)
import           Mappers          (wrapPolicy)
import           Serialization    (currencySymbol, writePolicyToFile, writeDataToFile) 
import GHC.Base (IO)

--THE ON-CHAIN CODE

{-# INLINABLE ieaNFT #-}
ieaNFT :: TxOutRef -> () -> ScriptContext -> Bool
ieaNFT utxo _ sContext = traceIfFalse "UTxO not available!" hasUTxO &&
                         traceIfFalse "There can be only ONE!" checkMintedAmount
        
    where
        hasUTxO :: Bool
        hasUTxO = any (\x -> txInInfoOutRef x == utxo) $ txInfoInputs info

        checkMintedAmount :: Bool
        checkMintedAmount = case flattenValue (txInfoMint info) of
            [(_, _, amt)] -> amt == 1
            _             -> False

        info :: TxInfo
        info = scriptContextTxInfo sContext


{-# INLINABLE eaNFT #-}
eaNFT :: TxOutRef -> Bool -> ScriptContext -> Bool
eaNFT utxo category sContext = case category of
        True  -> forging
        False -> burning        
    where
        forging = traceIfFalse "UTxO not available!" hasUTxO &&
                  traceIfFalse "There can be only ONE!" checkMintedAmount

        burning = traceIfFalse "Only burning one, nothing more, nothing less!" checkBurnedAmount 

        hasUTxO :: Bool
        hasUTxO = any (\x -> txInInfoOutRef x == utxo) $ txInfoInputs info

        checkMintedAmount :: Bool
        checkMintedAmount = case flattenValue (txInfoMint info) of
            [(_, _, amt)] -> amt == 1
            _             -> False

        checkBurnedAmount :: Bool
        checkBurnedAmount = case flattenValue (txInfoMint info) of
            [(_, _, amt)] -> amt == -1
            _             -> False

        info :: TxInfo
        info = scriptContextTxInfo sContext

{-# INLINABLE wrappediEAnftPolicy #-}
wrappediEAnftPolicy :: BuiltinData -> BuiltinData -> BuiltinData  -> BuiltinData -> ()
wrappediEAnftPolicy utxoId utxoIx = wrapPolicy $ ieaNFT utxo
    where
        utxo :: TxOutRef
        utxo = TxOutRef (TxId $ PlutusTx.unsafeFromBuiltinData utxoId) (PlutusTx.unsafeFromBuiltinData utxoIx)

ieaNFTcode :: PlutusTx.CompiledCode (BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData -> ())
ieaNFTcode = $$(PlutusTx.compile [|| wrappediEAnftPolicy ||])

ieaNFTPolicy :: TxOutRef -> MintingPolicy
ieaNFTPolicy utxoRef = mkMintingPolicyScript $
                          ieaNFTcode
                           `PlutusTx.applyCode` PlutusTx.liftCode (PlutusTx.toBuiltinData $ getTxId $ txOutRefId utxoRef)
                           `PlutusTx.applyCode` PlutusTx.liftCode (PlutusTx.toBuiltinData $ txOutRefIdx utxoRef)

-- The complete minting policy validator version

wrappedEAnftPolicy :: BuiltinData -> BuiltinData -> BuiltinData  -> BuiltinData -> ()
wrappedEAnftPolicy utxoId utxoIx = wrapPolicy $ eaNFT utxo
    where
        utxo :: TxOutRef
        utxo = TxOutRef (TxId $ PlutusTx.unsafeFromBuiltinData utxoId) (PlutusTx.unsafeFromBuiltinData utxoIx)

eaNFTcode :: PlutusTx.CompiledCode (BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData -> ())
eaNFTcode = $$(PlutusTx.compile [|| wrappedEAnftPolicy ||])

eaNFTPolicy :: TxOutRef -> MintingPolicy
eaNFTPolicy utxoRef = mkMintingPolicyScript $
                          eaNFTcode
                           `PlutusTx.applyCode` PlutusTx.liftCode (PlutusTx.toBuiltinData $ getTxId $ txOutRefId utxoRef)
                           `PlutusTx.applyCode` PlutusTx.liftCode (PlutusTx.toBuiltinData $ txOutRefIdx utxoRef)

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

param :: TxOutRef
param  = PlutusV2.TxOutRef { txOutRefId = "0e78111f4320736d5db8018e434f3804b153a5cc056524d01b1ef8cb20a5c30d"
                           , txOutRefIdx = 0}
param2 :: TxOutRef
param2  = PlutusV2.TxOutRef { txOutRefId = "2c33a52f8e0c15f3e8f080b38a6dfb378d8e78df6997e5b87bba706c89864833"
                           , txOutRefIdx = 0}
-- You have to provide your own UTxO TxID and Index on serialization of the minting policy validator.                       

saveieaNFTPolicy :: IO ()
saveieaNFTPolicy =  writePolicyToFile "./testnet/ieaNFT.plutus" $ ieaNFTPolicy param   

saveeaNFTPolicy :: IO ()
saveeaNFTPolicy =  writePolicyToFile "./testnet/eaNFT.plutus" $ eaNFTPolicy param   

saveeaNFTPolicy2 :: IO ()
saveeaNFTPolicy2 =  writePolicyToFile "./testnet/eaNFT2.plutus" $ eaNFTPolicy param2   

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

saveRedeemerForging :: IO ()
saveRedeemerForging = writeDataToFile "./testnet/Forge.json" True

saveRedeemerBurning :: IO ()
saveRedeemerBurning = writeDataToFile "./testnet/Burn.json" False

saveAll :: IO ()
saveAll = do
            saveieaNFTPolicy
            saveeaNFTPolicy2
            saveeaNFTPolicy
            saveUnit
            saveRedeemerForging
            saveRedeemerBurning
