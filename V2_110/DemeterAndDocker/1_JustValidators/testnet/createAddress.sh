#!/bin/sh
names=(alwaysSucceeds alwaysFails redeemer11 datum22 datum23)
for name in ${names[@]}; do
    cardano-cli address build --payment-script-file $name.plutus --testnet-magic 2 --out-file $name.addr
done

