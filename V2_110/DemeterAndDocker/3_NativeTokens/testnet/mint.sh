utxoin1="bcc6727c18b959cff0e65760e69bc5b220814f941c14ff7e056f1d85cd9b015b#4"
utxoin2=""
policyid=$(cat EAcoins.pid)
output="5500000"
tokenamount="100"
tokenname=$(echo -n "EAcoinsbat107" | xxd -ps | tr -d '\n')
collateral="c7e5859f6c3920e54bc81e6638980a749c5c897fb428cfe5611c99a57542cd7b#1"
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
  --mint-script-file EAcoins.plutus \
  --mint-redeemer-file OurRedeemer.json \
  --out-file mintTx.body

cardano-cli transaction sign \
    --tx-body-file mintTx.body \
    --signing-key-file ../../../wallets/person1.skey \
    $PREVIEW \
    --out-file mintTx.signed

cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed
