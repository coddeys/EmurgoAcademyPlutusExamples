utxoin="1ac6b83bf6c94070a5d0ca5320a73e2285f1367ff6fe7e5677790338d79d74f0#3"
address="$(cat datumEqRedeemer.addr)"
output="25000000"
PREVIEW="--testnet-magic 2"
nami=$Adr01


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file unit.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file True.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file value23.json \
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
