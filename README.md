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

      BTC/USD:0x3c9294d257c106a8b2eb3e3a2d9199b8cd78a9b7



Oracle Methodology can be found at:  



Documentation is noted in three ways:  From the Remix Solidity Browser,  From the Node.js commmand line, and from the MyEther wallet.  

For a non-technical overview of the product, please see the Whitepaper: https://docs.wixstatic.com/ugd/cd991f_7d5a46584fb046618428465c02fde738.pdf 


Remix:
Before you can use the Remix browser, you'll need to download metamask here: https://metamask.io/  

For now, you'll need to connect to the Ropsten test network until the contracts are out of Beta.  In order to get Ropsten testnet Ether, you can email info@decentralizedderivatives.org with your Ropsten address.  The Reddit/r/ethdev also gives out Ropsten for a different route: https://www.reddit.com/r/ethdev/comments/61zdn8/if_you_need_some_ropsten_testnet_ethers/ .

Once you have metamask with Ether, go to the remix browser at:https://ethereum.github.io/browser-solidity/  

Paste the following into the code field (delete everything else):
      
      pragma solidity ^0.4.13;
      import "https://github.com/DecentralizedDerivates/Deriveth/Factory.sol";

Now follow the instructions for each part:


To create a swap

      Factory - AtAddress("0x...")
        Enter .01 as value
        · Click Factory.CreateContract
        · Copy Returned Address (you're new Swap!)

To enter in details of your purchased contract:

      Swap - At address and enter the newly created Swap contract (e.g. 0x35d6a51eee77422820dcc7c51ab9148899a24daf  ) (note no quotation)
      · enter margin value (e.g. 100 eth)
      
      To calculate the date, you will need convert the date to hex.  Say you wanted July 20th 2017 to be the start date and July 27th 2017 to be the end date.  Go to a string to hex converter (https://codebeautify.org/string-hex-converter) and type in the firsts date in the YYYYMMDD format.  20170720  and get the result (3230313730373230).  Add a 0x to the front, and this is your start date.  Do this for the end Date as well.
      
      · Swap.createContract (ECP,margin,margin2,notional,long,startDate,endDate,cancellable) - 
          (e.g. true,100, 100, 1000, true, 0x3230313730373230, 0x3230313730373237)

      You're swap is now created!  Now you need a counterpary.  To incentivize counterparties, reduce Margin2 relative to margin

To modify:

      Swap - At address and enter the newly created Swap contract (e.g. 0x35d6a51eee77422820dcc7c51ab9148899a24daf  ) (note no quotation)
      · click exit
      -now you can re-enter your details
      
To enter as counterparty:

        · Find swap at addresss like above
        · enter margin2 value (e.g. 100 eth)
        · Enter swap with details of swap (besides your margin2 value ) Swap.EnterSwap (ECP,margin,notional,long,startDate,endDate,cancellable) - (e.g. true,100, 1000, true,  0x3230313730373230, 0x3230313730373237)

To calculate/pay Swap:
        Once the enddate has past:
        · One party needs to click Swap.Calculate()  (check currentState to see if this has been done (will be 2 once done))
        · Each party can now click Swap.PaySwap() to retrieve their payout
  


Node.js:

             //Note this needs work

            const Web3 = require("web3");
            const fs = require('fs');
            const Tx = require('ethereumjs-tx')
            const web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io"));
       //Now go get the factory ABI
            var abi = factory ABI (https://github.com/DecentralizedDerivatives/Deriveth/blob/master/abi)
            var contractAddress ="0x8d3cbc2cba343b97f656428eafa857ee01bda53b";
            var _ = require('lodash');
            var SolidityFunction = require('web3/lib/web3/function');
            var solidityFunction = new SolidityFunction('', _.find(abi, { name: 'createContract' }), '');
            var account1= "0xE5078b80b08bD7036fc0f7973f667b6aa9B4ddBE";
            var key1 = new Buffer('d941dcf24a8841fda45f3b0e52d2987a1f9131233caa3a0566b0c91910af85af', 'hex');
            var account2 = "0x939DD3E2DE8f472573364B3df1337857E758d90D"
            var key2 = new Buffer('f47e6311420a4fc5e900cb9aebec5387b7b56228bbeb887b7de424f8af9b1a74', 'hex');

            var gasLimitHex = web3.toHex(3000000);

            var numbernon=  web3.eth.getTransactionCount(account1) ;
            var nonceHex = web3.toHex(numbernon);
            var payloadData = solidityFunction.toPayload([]).data;

            var rawTx = {
                nonce: nonceHex,
                gasPrice: "0x04e3b29200", //this is a hack to get around issues on Ropsten via Infura
                gasLimit: gasLimitHex,
                to:contractAddress,
                value: web3.toHex(web3.toWei('.01', 'ether')),
                data: payloadData,
                chainId:3
            };
            
            var tx = new Tx(rawTx);
            tx.sign(key1);

            var serializedTx = tx.serialize();

            web3.eth.sendRawTransaction('0x' + serializedTx.toString('hex'), function (err, hash) {
                if (err) {
                    console.log('send raw Error:');
                    console.log(err);
                }
                else {
                    console.log('Transaction receipt hash pending');
                    console.log(hash);
                }
            });

            //To interact with Swap
            var abi = swapAbi
            var sContract = web3.eth.contract(abi);
            var contractAddress = "0xBd47D26065E97Cd8Db600687c64747efFB473c9A";
            var sInstance = sContract.at(contractAddress)

            //To create swap
            var SolidityFunction = require('web3/lib/web3/function');
            var solidityFunction = new SolidityFunction('', _.find(abi, { name: 'CreateSwap' }), '');
            
            var gasLimitHex = web3.toHex(3000000);

            var numbernon=  web3.eth.getTransactionCount(account1) ;
            var nonceHex = web3.toHex(numbernon);
            var payloadData = solidityFunction.toPayload([true,1, 1, 10, true, web3.fromAscii("20170714"),web3.fromAscii("20170717")]).data;
            //gasPrice is a hack to get around issues on Ropsten via Infura
            var rawTx = {
                nonce: nonceHex,
                gasPrice: "0x04e3b29200", 
                gasLimit: gasLimitHex,
                to:contractAddress,
                value: web3.toHex(web3.toWei('1', 'ether')),
                data: payloadData,
                chainId:3
            };
            
            var tx = new Tx(rawTx);
            tx.sign(key1);
            var serializedTx = tx.serialize();
            web3.eth.sendRawTransaction('0x' + serializedTx.toString('hex'), function (err, hash) {
                if (err) {
                    console.log('send raw Error:');
                    console.log(err);
                }
                else {
                    console.log('Transaction receipt hash pending');
                    console.log(hash);
                }
            });
            

            //To view details and enter a swap
             console.log('Notional-', sInstance.notional.call().toNumber(), ' Long-',sInstance.long.call(),' Long Margin-',sInstance.lmargin.call().toNumber(),' Short Margin-',sInstance.smargin.call().toNumber(),' StartDate-',web3.toAscii(sInstance.startDate.call()),' endDate-',web3.toAscii(sInstance.endDate.call()));

            To enter, do same steps as above, but delete your margin from the payloadData:
            var solidityFunction = new SolidityFunction('', _.find(abi, { name: 'EnterSwap' }), '');
            var payloadData = solidityFunction.toPayload([true,1, 10, true, web3.fromAscii("20170714"),web3.fromAscii("20170717")]).data;

            //Then calculate and Pay
            var solidityFunction = new SolidityFunction('', _.find(abi, { name: 'Calculate' }), '');
            var payloadData = solidityFunction.toPayload(]).data;
            var rawTx = {
                nonce: nonceHex,
                gasPrice: "0x04e3b29200", //this is a hack to get around issues on Ropsten via Infura
                gasLimit: gasLimitHex,
                to:contractAddress,
                data: payloadData,
                chainId:3
            };
            
            var solidityFunction = new SolidityFunction('', _.find(abi, { name: 'PaySwap' }), '');
            var payloadData = solidityFunction.toPayload([]).data;
            var rawTx = {
                nonce: nonceHex,
                gasPrice: "0x04e3b29200", //this is a hack to get around issues on Ropsten via Infura
                gasLimit: gasLimitHex,
                to:contractAddress,
                data: payloadData,
                chainId:3
            };


MyEther Wallet:

      Download and install metamask: https://metamask.io/

      Go to: https://www.myetherwallet.com/#contracts  

      Enter in contract Address from above.  

      Enter abi ---  [{"constant":true,"inputs":[],"name":"creator","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"createContract","outputs":[{"name":"","type":"address"}],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"_fee","type":"uint256"}],"name":"setFee","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"newContracts","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"withdrawFee","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"oracleID","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_oracleID","type":"address"}],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_name","type":"address"},{"indexed":false,"name":"_value","type":"address"}],"name":"Print","type":"event"}]

      Click create contract and click 'Metamask/Mist' option
      Click connect to metamask and write
      Type in fee (.01), and then click to make transaction.
      Grab transaction hash, or get it from your metamask transactions
      To get address, view transaction on Etherscan.io
            Click the 'Internal Transactions' tab
            The 'To' field is your new contract address

      ............
      /*To enter open / create new contract*/

      Enter in Swap Address
      Enter abi (found here)
      Click 'Create Swap'
      Enter in details and then submit

      ............
      /* To pay */

      Enter Swap Address
      Etner abi (found here) 
      Click 'Calculate'
      Click 'Pay Swap'
