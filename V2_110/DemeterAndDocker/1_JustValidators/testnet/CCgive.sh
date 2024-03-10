utxoin="3a92745c9a5a90e72174fd2a3c8e6894ce00fcab33d2f968ef754d4fd4d0bcd4#0"
address="$(cat conditionator.addr)"
output="5000000"
PREVIEW="--testnet-magic 2"


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file datum.json \
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
 
