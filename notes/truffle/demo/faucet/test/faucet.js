const truffleAssert = require("truffle-assertions");
const BigNumber = require("bignumber.js");
const Faucet = artifacts.require("Faucet");

contract("Faucet", (accounts) => {
  const creator = accounts[0];
  const donor = accounts[1];
  const benificiary = accounts[2];
  const withdrawalAmount = 200000000000000000;
  const refillAmount = 1000000000000000000;
  let faucetInstance;

  describe("positive", () => {
    before(async () => {
      faucetInstance = await Faucet.deployed({ from: creator });
      await web3.eth.sendTransaction({
        from: donor,
        to: faucetInstance.address,
        value: refillAmount,
      });
      const balance = await web3.eth.getBalance(faucetInstance.address);
      assert.equal(refillAmount, balance, "It should be equal");
    });

    it("it should be able to withdraw using withdraw()", async () => {
      const beneficiaryBalance = await web3.eth.getBalance(benificiary);
      const tx = await faucetInstance.withdraw(
        web3.utils.toBN(withdrawalAmount),
        { from: benificiary }
      );
      // Obtain gasPrice from the transaction
      const trx = await web3.eth.getTransaction(tx.receipt.transactionHash);
      const beneficiaryNewBalance = await web3.eth.getBalance(benificiary);

      const calculatedBenificiaryBalance = web3.utils
        .toBN(beneficiaryBalance)
        .add(web3.utils.toBN(withdrawalAmount))
        .sub(
          web3.utils.toBN(tx.receipt.gasUsed).mul(web3.utils.toBN(trx.gasPrice))
        )
        .toString();
      truffleAssert.eventEmitted(tx, "Withdrawal", (obj) => {
        return (
          obj.to === benificiary &&
          new BigNumber(obj.amount).isEqualTo(web3.utils.toBN(withdrawalAmount))
        );
      });
      assert.equal(
        beneficiaryNewBalance,
        calculatedBenificiaryBalance,
        "It should be equal"
      );
    });
  });
  describe("negative", () => {
    it("it should revert on withdraw if exceeds contract balance", async () => {
      await truffleAssert.reverts(
        faucetInstance.withdraw(web3.utils.toBN(refillAmount), {
          from: benificiary,
        }),
        "Faucet: Insufficient balance for withdrawal request"
      );
    });
  });
});
