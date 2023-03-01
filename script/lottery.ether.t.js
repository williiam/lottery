import { ethers } from 'ethers';
import lotteryContractAbi from "../build/contracts/Lottery.json" assert { type: 'json' };

const url = "http://localhost:8545";
const network = {
    // name: "sepolia",
    // chainId: 1337
};

// BUG
// const provider = new ethers.JsonRpcProvider(url, network);
const _provider = new ethers.JsonRpcProvider(url);

// The provider also allows signing transactions to
// send ether and pay to change state within the blockchain.
// For this, we need the account signer...

// const signer = provider.getSigner()

const ethPrivkey = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d"

const wallet = new ethers.Wallet(ethPrivkey, _provider);
const provider = wallet.provider;

const signer = await provider.getSigner(wallet.address);
const _network = await provider.getNetwork()
const blockNumber = await provider.getBlockNumber();

const balance = await provider.getBalance(wallet.address)

const formatbalance = ethers.formatEther(balance)

const parsedEther = ethers.parseEther("1.0")

// poke the lottery contract
const contractAddress = "0xCfEB869F69431e42cdB54A4F4f105C19C080A601";

const abi = lotteryContractAbi.abi;

const lotteryContract = new ethers.Contract(contractAddress, lotteryContractAbi.abi, provider);

const adr = lotteryContract.getAddress();
const dep = lotteryContract.getDeployedCode();

// watch contract event
lotteryContract.on('NewPlayer', (from, value, event) => {
    console.log(from, 'NewPlayer the lottery with', value.toString());
});

// call contract methid
const value = 42;
const tx = await lotteryContract.joinLottery(value);
const transactionReceipt = await tx.wait();
if (transactionReceipt.status !== 1) {
    alert('error message');
}
