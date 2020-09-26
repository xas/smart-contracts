const Dai = artifacts.require("Dai");
const Gesell = artifacts.require("Gesell");
var BN = web3.utils.BN;

contract("testing with dai tokens", async accounts => {
  it("should send coin correctly", async () => {

    // Get initial balances of first and second account.
    let account_one = accounts[0];
    let account_two = accounts[1];

    // define the amount to test
    let amount = web3.utils.toWei('10');
    let tokenBuy = web3.utils.toWei('5');
    let tokenTransfer = web3.utils.toWei('1');

    // get the instance for the dai token
    let instance = await Dai.deployed();

    // get some dai to start
    await instance.mint(account_one, amount, { from: account_one });
    await instance.mint(account_two, amount, { from: account_one });

    // instance of the gesell token
    let gInst = await Gesell.deployed();

    // approve for the dai transferFrom
    await instance.approve(gInst.address, tokenBuy, { from: account_one });
    await instance.approve(gInst.address, tokenBuy, { from: account_two });
    
    // buy some gesell
    let ret = await gInst.buy(tokenBuy, { from: account_one });
    ret = await gInst.buy(tokenBuy, { from: account_two });
    let beforeTransferOne = await gInst.balanceOf.call(account_one);
    let beforeTransferTwo = await gInst.balanceOf.call(account_two);

    ret = await gInst.transfer(account_one, tokenTransfer, { from: account_two });

    let afterTransferOne = await gInst.balanceOf.call(account_one);
    let afterTransferTwo = await gInst.balanceOf.call(account_two);

    assert.equal(
      beforeTransferOne.toString(),
      beforeTransferTwo.toString(),
      "Should start with same amount of Gesell tokens"
    );

    assert.equal(
      new BN(tokenTransfer).sub(new BN('1')).toString(),
      afterTransferOne.sub(beforeTransferOne).toString(),
      "Should have one Gesell token diff"
    );
  });
});