const Web3 = require('web3')
const crypexInterface = require('../build/contracts/Crypdex.json');

const web3 = new Web3('ws://127.0.0.1:8545')

const { CONTRACT_ADDR } = require('./runValues.json')
const ACC_ADDR = '0xE4936D15019c34022b31A5deb815aC7b7e1f15a8'
const ACC_PK = '0x45cbaeb1efa81f5416eb068af218e951db5fa47fe9bc9e098570a684d0b62ec4'
const WETH9 = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'

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

  crypdex.events.allEvents({}, (err, { event, returnValues: {'0': val} }) => {
    console.log('Event:', event, '- Value:', web3.utils.fromWei(val))
  })

  const result = await crypdex.methods.swip().send({
    from: ACC_ADDR,
    gas: 2000000,
    value: web3.utils.toWei('2'),
  })
  logBalances()
}

test()
