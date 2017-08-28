# Deriveth
Deriveth is a Customized Derivatives Contract based on the Decentralized Derivatives Oracles.
The following contracts and products are available on the Ropsten test network.

Join us on our slack: https://deriveth.slack.com/

Or on Gitter: https://gitter.im/deriveth

Open Deriveth Contract Factories:
Mainnet:

      ETH/USD:

      BTC/USD:
Ropsten:

      ETH/USD:

      BTC/USD:



Oracle Methodology can be found at:  



Documentation is noted in three ways:  From the Remix Solidity Browser,  From the Node.js commmand line, and from the mist wallet.  

Detailed technical documentation can be found at: https://readthedocs.org/projects/deriveth/ 

For a non-technical overview of the product, please see the Whitepaper:https://github.com/DecentralizedDerivatives/Deriveth/wiki/Whitepaper 


Remix:

      Factory - AtAddress("0x...")
        Enter .01 as value
        · Click Factory.CreateContract
        · Copy Returned Address (you're new Swap!)


      Swap - At address and enter the newly created Swap contract (e.g. 0x35d6a51eee77422820dcc7c51ab9148899a24daf  ) (note no quotation)
      · enter margin value (e.g. 100 eth)
      · Swap.createContract (ECP,margin,margin2,notional,long,startDate,endDate,cancellable) - 
          (e.g. true,100, 100, 1000, true, 20170701, 20170703)

      You're swap is now created!  Now you need a counterpary.  To incentivize counterparties, reduce Margin2 relative to margin

        To enter as counterparty:
        · Find swap at addresss like above
        · enter margin2 value (e.g. 100 eth)
        · Swap.EnterSwap (ECP) - (e.g. true)

      Once the enddate has past:
        · One party needs to click Swap.Calculate()  (check currentState to see if this has been done (will be 2 once done))
        · Each party can now click Swap.PaySwap() to retrieve their payout
  


Node.js:

             //Note this needs work

            const fs = require('fs');
            const solc = require('solc');
            const Web3 = require('web3');

            var account1 = "0.....";  (this is your address)
            var key2 = new Buffer('f47e6311420a4fc5e900cb9aebec5387b7b56228bbeb887b7de424fxxxxxxxxx, 'hex') /*this is your private key*/
            web3.eth.defaultAccount = account1

            // Connect to local Ethereum node
            const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

            // Compile the source code
            const input = fs.readFileSync('Master.sol');
            const output = solc.compile(input.toString(), 1);

            //To create a contract
            const bytecode = output.contracts['Factory'].bytecode;
            const abi = JSON.parse(output.contracts['Factory'].interface);

            var fContract = web3.eth.contract(abi)
            var fInstance = fContract.at('0x......')
            fInstance.createContract({value:web3.toWei('.01', 'ether') margin, gas: 3000000})

            //To interact with Swap
            const bytecode = output.contracts['Swap'].bytecode;
            const abi = JSON.parse(output.contracts['Swap'].interface);
            var sContract = web3.eth.contract(abi)
            var sInstance = sContract.at('0x......')

            //To create swap
            sInstance.CreateSwap(true,100, 100, 1000, true, web3..fromAscii("20170714"),web3..fromAscii("20170717"),{value:web3.toWei('100', 'ether') gas: 3000000});


            //To view details and enter a swap
             console.log('Notional-', sInstance.notional.call().toNumber(), ' Long-',sInstance.long.call(),' Margin1-',sInstance.margin1.call().toNumber(),' Margin2-',sInstance.margin2.call().toNumber(),' StartDate-,web3..toAscii(sInstance.startDate.call()),' endDate-',web3..toAscii(sInstance.endDate.call()));

            sContractInstance.EnterSwap(true{value:web3.toWei('100', 'ether') ,gas: 3000000});

            //Then calculate and Pay
            sInstance.Caluclate({gas: 3000000});
            sInstance.PaySwap({gas: 3000000});



MyEther Wallet:

Download and install metamask: https://metamask.io/

Go to: https://www.myetherwallet.com/#contracts  

Enter in contract Address from above.  

Enter bytecode (list can be found here)

Click create contract and get address
      To get address, view transaction on Etherscan.io
      Click the 'Internal Transactions' tab
      The 'To' field is your new contract address

............
/*To enter open / create new contract*/

Enter in Swap Address
Enter bytecode 
Click 'Create Swap'
Enter in details and submit

............
/* To pay */

Enter Swap Address
Etner bytecode 
Click 'Calculate'
Click 'Pay Swap'
