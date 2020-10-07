const Dai = artifacts.require("Dai");
const Fidelity = artifacts.require("Fidelity");
var BN = web3.utils.BN;

contract("testing with ethers", async accounts => {
  it("should send coin correctly", async () => {

    // Get initial balances of first and second account.
    let account_one = accounts[0];
    let account_two = accounts[1];

    let amount = web3.utils.toWei('10');
    let tokenBuy = web3.utils.toWei('5');
    let tokenTransfer = web3.utils.toWei('1');

    let gInst = await Fidelity.deployed();

    await web3.eth.sendTransaction({from:account_one, to:gInst.address, value: amount});
    await web3.eth.sendTransaction({from:account_two, to:gInst.address, value: amount});

    let beforeTransferOne = await gInst.balanceOf.call(account_one);
    let beforeTransferTwo = await gInst.balanceOf.call(account_two);

    ret = await gInst.transfer(account_one, tokenTransfer, { from: account_two });

    let afterTransferOne = await gInst.balanceOf.call(account_one);
    let afterTransferTwo = await gInst.balanceOf.call(account_two);

    assert.equal(
      beforeTransferOne.toString(),
      beforeTransferTwo.toString(),
      "Should start with same amount of Fidelity tokens"
    );

    assert.equal(
      new BN(tokenTransfer).sub(new BN('250')).toString(),
      afterTransferOne.sub(beforeTransferOne).toString(),
      "Should have one Fidelity token diff"
    );
  });
});