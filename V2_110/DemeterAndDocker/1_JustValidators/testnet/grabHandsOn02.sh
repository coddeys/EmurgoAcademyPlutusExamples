utxoinUnit="114d55c1dc87427f86e3550d5fa98b13affb1f068949a76400da8ed8866b81e5#0"
utxoinValue33="114d55c1dc87427f86e3550d5fa98b13affb1f068949a76400da8ed8866b81e5#2"
utxoinTrue="114d55c1dc87427f86e3550d5fa98b13affb1f068949a76400da8ed8866b81e5#1"
utxoinFalse="114d55c1dc87427f86e3550d5fa98b13affb1f068949a76400da8ed8866b81e5#1"

address=$(cat ../../../wallets/person1.addr)
output="60814015"
collateral="c49347b49f323fdac6d59b21543a1df870c93b90810603df8cbdd3025eee1881#1"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
nami=$Adr01
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoinUnit \
  --tx-in-script-file typedDatumEqRedeemerValidator.plutus \
  --tx-in-datum-file unit.json \
  --tx-in-redeemer-file joker.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami \
  --out-file grab.unsigned

# cardano-cli transaction sign \
#     --tx-body-file grab.unsigned \
#     --signing-key-file ../../../wallets/person1.skey \
#     $PREVIEW \
#     --out-file grab.signed

# cardano-cli transaction submit \
#     $PREVIEW \
#     --tx-file grab.signed
