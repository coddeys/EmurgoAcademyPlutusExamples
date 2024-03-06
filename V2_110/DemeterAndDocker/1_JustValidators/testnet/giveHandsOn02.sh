utxoin="114d55c1dc87427f86e3550d5fa98b13affb1f068949a76400da8ed8866b81e5#4"
address="$(cat typedDatumEqRedeemerValidator.addr)"
output="15000000"
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file owduUnit.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file owdi33.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file owdbTrue.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file owdbFalse.json \
  --change-address $Adr01 \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file give.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed
