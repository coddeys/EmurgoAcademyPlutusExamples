utxoin1="c7e5859f6c3920e54bc81e6638980a749c5c897fb428cfe5611c99a57542cd7b#1"
policyid=$(cat EAcoins.pid)
tokenamount="-100"
tokenname=$(echo -n "EAcoinsbat107" | xxd -ps | tr -d '\n')
collateral="c7e5859f6c3920e54bc81e6638980a749c5c897fb428cfe5611c99a57542cd7b#1"
signerPKH="8b225ceddb05738d7a53bd130136e187a6f0baa4d219161fed4f2ac0"
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in "c9899a4a611bc7d105829dda4a2473a5f6733568d67bc265e7bfde30814547bf#0"  \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --change-address $Adr01 \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file EAcoins.plutus \
  --mint-redeemer-file OurRedeemer.json \
  --out-file burnTx.body

cardano-cli transaction sign \
    --tx-body-file burnTx.body \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file burnTx.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file burnTx.signed
