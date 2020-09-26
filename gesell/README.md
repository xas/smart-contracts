# Gesell Token

The _Gesell token_ is project to implement a `melting currency` as proposed by _Silvio Gesell_ in his book **The Natural Economic Order**

This token implementation has no logical buy price.

This version 0.6.0 work with a defined melting process :

* at first buy/transfer of token your address is set with the current timestamp
* at the next buy/transfer you do, a comparison is made from your last transfer
* if your last transfer has been made during the last week, 1 token is burnt before the transfer
* if your last transfer has been made between one week and two weeks, 10 tokens are burnt before the transfer
* if your last transfer has been made between two weeks and three weeks, 50 tokens are burnt before the transfer
* if your last transfer has been made between three weeks and four weeks, 100 tokens are burnt before the transfer
* if your last transfer has been made after a month, 250 tokens are burnt before the transfer
* after a successfull transfer, your timestamp is reset

### Remarks

If your current balance is smaller than the burnt rule, the transfer will never succeed. Your tokens are blocked until you buy more.

## Future

Actually the number of token to burn is fixed, whatever can be your amount to transfer.  
One possible way for the future could be a percentage computation. But there is a drawback :

* you can transfer a minimal amount used to reset your timestamp and then transfer a larger amount
