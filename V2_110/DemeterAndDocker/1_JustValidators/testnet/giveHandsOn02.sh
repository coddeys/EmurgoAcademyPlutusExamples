utxoin="6258c575862b8c7b77fe68730d9651632f3426720218ae1ede743f615c82f8fd#3"
address="$(cat typedDatumEqRedeemerValidator.addr)"
output="15000000"
PREVIEW="--testnet-magic 2"
nami=$Adr01

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
