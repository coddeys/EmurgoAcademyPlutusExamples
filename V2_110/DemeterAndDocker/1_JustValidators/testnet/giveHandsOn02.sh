utxoin="132e58a7dbe205032676ea69a10f918245a3a56820044d9472f342f01a8a0ce3#0"
address="$(cat typedDatumEqRedeemerValidator.addr)"
output="15000000"
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file unit.json \
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
