utxoin1="0e78111f4320736d5db8018e434f3804b153a5cc056524d01b1ef8cb20a5c30d#0"
utxoin2="2c33a52f8e0c15f3e8f080b38a6dfb378d8e78df6997e5b87bba706c89864833#0"
policyid=$(cat eaNFT.pid)
output="10000000"
tokenamount="1"
tokenname=$(echo -n "EAnft" | xxd -ps | tr -d '\n')
collateral="b43a45250de8237ce169c3a7ca21b32e4d30709f47080b42c7751a5a66e53dcb#1"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $nami+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $Adr01 \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file eaNFT.plutus \
  --mint-redeemer-file Forge.json \
  --out-file mintEAnftTx.body

cardano-cli transaction sign \
    --tx-body-file mintEAnftTx.body \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file mintEAnftTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintEAnftTx.signed
