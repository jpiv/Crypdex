const Web3 = require('web3')
const crypexInterface = require('../artifacts/contracts/Crypdex.sol/Crypdex.json');

const web3 = new Web3('ws://localhost:8545')

const { CONTRACT_ADDR } = require('./runValues.json')
const ACC_ADDR = '0xbcd4042de499d14e55001ccbb24a551f3b954096'

const crypdex = new web3.eth.Contract(crypexInterface.abi, CONTRACT_ADDR);

const getBalance = async addr => web3.utils.fromWei(await web3.eth.getBalance(addr)) 
const logBalances = async () => {
  const contractBalance = await getBalance(CONTRACT_ADDR)
  const accBalance = await getBalance(ACC_ADDR)

  console.log('Contract Balance:', contractBalance)
  console.log('Account Balance:', accBalance)
}

const test = async () => {
  await logBalances()

  crypdex.events.allEvents({}, (err, e) => {
    const { event, returnValues: {'0': val} } = e
    console.log('Event:', event, '- Value:', val)
  })


  // Initial ETH deposit
  await crypdex.methods.deposit().send({
    from: ACC_ADDR,
    gas: 2000000,
    value: web3.utils.toWei('1'),
  })

  // Purchase fund
  await crypdex.methods.purchaseFund().send({
    from: ACC_ADDR,
    gas: 2000000,
  })


  logBalances()
}

test()
