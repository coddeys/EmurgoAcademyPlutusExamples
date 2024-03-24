utxoin="07cdcebce1c1918f8e28347fe5351ddb32743dc6b3f5ddd28a6064ed09b923bf#2"
output="320000000"
collateral="b43a45250de8237ce169c3a7ca21b32e4d30709f47080b42c7751a5a66e53dcb#1"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
nami="addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt" 
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file mathBounty.plutus \
  --tx-in-datum-file DimaConditions.json \
  --tx-in-redeemer-file value-18.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $Adr01+$output \
  --change-address $nami \
  --invalid-hereafter 44663207 \
  --out-file unlock.unsigned 

cardano-cli transaction sign \
    --tx-body-file unlock.unsigned \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file unlock.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file unlock.signed
