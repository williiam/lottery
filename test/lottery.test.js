const Lottery = artifacts.require('Lottery');
contract('Lottery', function () {
    it(`should get players , length 0`, async () => {
        let instance = await Lottery.deployed();
        const players = await instance.getPlayers();
        assert.equal(players.length, 0);
    });

    it(`should register 2 players and have a winner`, async () => {
        let instance = await Lottery.deployed();

        let winnerEventEmitted = false;
        // listen for WinnerSelected event
        // instance.WinnerSelected().on('data', (event) => {
        //     console.log('WinnerSelected', event);
        //     winnerEventEmitted= true;
        // });

        const accounts = await web3.eth.getAccounts();
        await instance.joinLottery({ from: accounts[0], value: web3.utils.toWei('0.02', 'ether') });
        await instance.joinLottery({ from: accounts[1], value: web3.utils.toWei('0.05', 'ether') });

        const players = await instance.getPlayers();

        assert.equal(players.length, 0);
        // assert.equal(winnerEventEmitted, true);
    });
});