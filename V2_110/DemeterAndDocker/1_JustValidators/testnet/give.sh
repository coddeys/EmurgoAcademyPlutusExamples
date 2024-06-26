utxoin="8e48832ccb8a77f809718b0635ffefbe452c1e236ab1f0d2bb93adb4d08b1760#0"
address="$(cat datumEqRedeemer.addr)"
output="7000000"
PREVIEW="--testnet-magic 2"
nami=$Adr01


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file True.json \
  --change-address $nami \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed
 
