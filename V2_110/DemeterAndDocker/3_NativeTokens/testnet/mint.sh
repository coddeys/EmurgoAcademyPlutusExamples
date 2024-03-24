utxoin1="83b1e8555a575e8cb87fbee0e102845fa0a63e24e904c961b3bd2f47babb7db5#1"
policyid=$(cat StartupCoins.pid)
output="5500000"
tokenamount="100"
tokenname=$(echo -n "EAcoinsbat107" | xxd -ps | tr -d '\n')
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
  --mint-script-file StartupCoins.plutus \
  --mint-redeemer-file OurRedeemer.json \
  --out-file mintTx.body

# cardano-cli transaction sign \
#     --tx-body-file mintTx.body \
#     --signing-key-file ../../../wallets/person1.skey \
#     $PREVIEW \
#     --out-file mintTx.signed

# cardano-cli transaction submit \
#     $PREVIEW \
#     --tx-file mintTx.signed
