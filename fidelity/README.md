# Fidelity Token

The _Fidelity token_ is project to implement a `keeper trust` token, an idea I got when playing with DeFi tokens

This token implementation has no logical buy price.

This version 0.4.0 work with a defined melting process :

* at first buy/transfer of token your address is set with the current timestamp
* at the next buy/transfer you do, a comparison is made from your last transfer
* if your last transfer has been made in less than 6 hours, 250 token is burnt before the transfer
* if your last transfer has been made between 6 hours and 12 hours, 100 tokens are burnt before the transfer
* if your last transfer has been made between 12 hours and 24 hours, 50 tokens are burnt before the transfer
* if your last transfer has been made between 24 hours and 48 hours, 25 tokens are burnt before the transfer
* if your last transfer has been made between 48 hours and 72 hours, 1 tokens are burnt before the transfer
* if your last transfer has been made after 72 hours, no tokens are burnt
* after a successfull transfer, your timestamp is reset

### Remarks

It is not the same than a lock or vested system. You can move all your tokens. It's just you will lost some of them if transferred too early.  

If your current balance is smaller than the burnt rule, the transfer will never succeed. Your tokens are blocked until you buy more or wait enough time.

## Deploys

The contract (v0.4.0) has been deployed in these networks :

* [Goerli](https://goerli.etherscan.io/address/0xdB10341B063a04464f90Ca64ceE486a2501A0E56)

## Future

Should put some thougts about burning differences between `transfer` and `transferFrom`. This could be interesting