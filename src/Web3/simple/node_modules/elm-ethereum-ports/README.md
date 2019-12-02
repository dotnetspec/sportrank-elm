# elm-ethereum-ports

Easily connect Elm ports to your dapp.

Includes `txSentry` and `walletSentry`

See [elm-ethereum-simple-example](https://github.com/cmditch/elm-ethereum/tree/master/examples/simple) for usage.  

**TxSentry**  
Needed to wire into a wallet and send/track transactions.  
Currently only supports Metamask, which uses web3.js v0.20.3  

**WalletSentry**  
Very useful for monitoring account and networkId changes, and letting your Elm app know.
Currently polls for account changes every 500ms.  
