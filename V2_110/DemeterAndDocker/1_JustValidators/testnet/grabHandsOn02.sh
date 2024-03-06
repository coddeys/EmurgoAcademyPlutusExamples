utxoinUnit="71c541d8d2c1240e0767647ec610359fc512cc6ce1851489d7341718f19222dd#0"
utxoinValue33="71c541d8d2c1240e0767647ec610359fc512cc6ce1851489d7341718f19222dd#1"
utxoinTrue="71c541d8d2c1240e0767647ec610359fc512cc6ce1851489d7341718f19222dd#2"
utxoinFalse="71c541d8d2c1240e0767647ec610359fc512cc6ce1851489d7341718f19222dd#3"

address=$(cat ../../../wallets/person1.addr)
output="59402168"
collateral="c49347b49f323fdac6d59b21543a1df870c93b90810603df8cbdd3025eee1881#1"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
nami=$Adr01
PREVIEW="--testnet-magic 2"

# cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoinUnit \
  --tx-in-script-file typedDatumEqRedeemerValidator.plutus \
  --tx-in-datum-file owduUnit.json \
  --tx-in-redeemer-file joker.json \
  --tx-in $utxoinValue33 \
  --tx-in-script-file typedDatumEqRedeemerValidator.plutus \
  --tx-in-datum-file owdi33.json \
  --tx-in-redeemer-file owri33.json \
  --tx-in $utxoinTrue \
  --tx-in-script-file typedDatumEqRedeemerValidator.plutus \
  --tx-in-datum-file owdbTrue.json \
  --tx-in-redeemer-file owdbTrue.json \
  --tx-in $utxoinFalse \
  --tx-in-script-file typedDatumEqRedeemerValidator.plutus \
  --tx-in-datum-file owdbFalse.json \
  --tx-in-redeemer-file owdbFalse.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami \
  --out-file grab.unsigned

cardano-cli transaction sign \
    --tx-body-file grab.unsigned \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file grab.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grab.signed
