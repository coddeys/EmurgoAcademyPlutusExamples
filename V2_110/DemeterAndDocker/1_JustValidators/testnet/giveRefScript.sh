utxoin="d8423c3a30c28b783c472760cb3ef953ba848b333e213fcea5d9867ffd1ea203#3"
address="$(cat datumEqRedeemer.addr)"
# address="$(cat alwaysFails.addr)"
output="25000000"
PREVIEW="--testnet-magic 2"
# https://preview.cexplorer.io/tx/6258c575862b8c7b77fe68730d9651632f3426720218ae1ede743f615c82f8fd

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file unit.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file True.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file value23.json \
  --tx-out-reference-script-file datumEqRedeemer.plutus \
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
