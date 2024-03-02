utxoinUnit="d8423c3a30c28b783c472760cb3ef953ba848b333e213fcea5d9867ffd1ea203#0"
utxoinTrue="d8423c3a30c28b783c472760cb3ef953ba848b333e213fcea5d9867ffd1ea203#1"
utxoinValue23="d8423c3a30c28b783c472760cb3ef953ba848b333e213fcea5d9867ffd1ea203#2"
address=$(cat ../../../wallets/person1.addr)
output="74814015"
collateral="c49347b49f323fdac6d59b21543a1df870c93b90810603df8cbdd3025eee1881#1"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
nami=$Adr01
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoinUnit \
  --tx-in-script-file datumEqRedeemer.plutus \
  --tx-in-datum-file unit.json \
  --tx-in-redeemer-file unit.json \
  --tx-in $utxoinTrue \
  --tx-in-script-file datumEqRedeemer.plutus \
  --tx-in-datum-file True.json \
  --tx-in-redeemer-file True.json \
  --tx-in $utxoinValue23 \
  --tx-in-script-file datumEqRedeemer.plutus \
  --tx-in-datum-file value23.json \
  --tx-in-redeemer-file value23.json \
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
