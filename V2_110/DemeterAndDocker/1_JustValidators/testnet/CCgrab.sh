utxoin="c7e5859f6c3920e54bc81e6638980a749c5c897fb428cfe5611c99a57542cd7b#0"
address=$(cat conditionator.addr)
output="1000000"
collateral="0e78111f4320736d5db8018e434f3804b153a5cc056524d01b1ef8cb20a5c30d#0"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file conditionator.plutus \
  --tx-in-datum-file datum.json \
  --tx-in-redeemer-file unit.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --tx-out-datum-hash-file datum.json \
  --tx-out $Adr01+$output \
  --change-address $Adr01 \
  --out-file grab.unsigned

cardano-cli transaction sign \
    --tx-body-file grab.unsigned \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file grab.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grab.signed
