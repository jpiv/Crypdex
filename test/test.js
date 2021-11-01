const Web3 = require('web3')
const crypexInterface = require('../build/contracts/Crypdex.json');

const web3 = new Web3('ws://127.0.0.1:8545')

const CONTRACT_ADDR = '0x15F6AE087aB3667C782aC5A15D9Af720D0b0E19e'
const ACC_ADDR = '0x81359D53b4ccd4E9Ab6f74503923d624c73f1969'
const ACC_PK = '0x0798d9bed8fafe4be2cca39c114743e4497a6b30e36c6819ef491498b147f619'

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
  await web3.eth.accounts.wallet.add(ACC_PK)

  crypdex.events.RecievedAmount({}, (err, event) => {
    if (!err) {
      console.log('Contract received amount:',
        web3.utils.fromWei(event.returnValues.value)
      )
    }
  })

  await web3.eth.sendTransaction({
    to: CONTRACT_ADDR,
    from: ACC_ADDR,
    gas: 200000,
    value: web3.utils.toWei('1'),
  })


  logBalances()
}

test()
