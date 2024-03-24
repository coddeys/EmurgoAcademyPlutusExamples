utxoin1="a006070648e9d682ecbfe52cb94179f941d0aa88dbfaa17d9ac1ccfbdab7d23a#1"
policyid=$(cat StartupCoins.pid)
output="5900000"
tokenamount="250"
tokenname=$(echo -n "StartupCoins" | xxd -ps | tr -d '\n')
collateral="b43a45250de8237ce169c3a7ca21b32e4d30709f47080b42c7751a5a66e53dcb#1"
signerPKH1="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
signerPKH2="6efff2244d9f67a1a383db4a198a10c647408767cdcb0a44845ce15a"
nami2="addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt"
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $signerPKH1 \
  --required-signer-hash $signerPKH2 \
  --tx-in-collateral $collateral \
  --tx-out $nami2+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $Adr01 \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file StartupCoins.plutus \
  --mint-redeemer-file BothRedeemer.json \
  --out-file mintTx.body

cardano-cli transaction sign \
    --tx-body-file mintTx.body \
    --signing-key-file ../../../wallets/person1.skey \
    --signing-key-file ../../../wallets/person2.skey \
    $PREVIEW \
    --out-file mintTx.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed
