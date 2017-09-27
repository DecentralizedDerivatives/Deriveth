# Deriveth
Deriveth is a Customized Swap Contract based on the DDA Oracles.
The following contracts and products are available for review and on the Ropsten test network.

DDA website - www.decentralizedderivatives.org

Join us on our slack: https://deriveth.slack.com/

Or Gitter: https://gitter.im/deriveth

Factory Contracts on Ropsten:

      ETH/USD:0x222be967c2265ab0981c1686665facfe39b54f88

      BTC/USD:0x0dfdba3300d42f929ef83a996ae085f258754b44





Oracle Methodology can be found at:  
https://github.com/DecentralizedDerivatives/Oracles

     Oracle Test Values (this is BTC, but ETH is the same) 
	"0x01","BTCUSD",1000
	"0x02","BTCUSD",950
	"0x03","BTCUSD",800
	"0x04","BTCUSD",1050
	"0x05","BTCUSD",1200


Documentation is noted in three ways:  From the Remix Solidity Browser,  From the Node.js commmand line, and from the MyEther wallet.  

For a non-technical overview of the product, please see the Whitepaper: https://docs.wixstatic.com/ugd/cd991f_80ee35841dcd456cbd27fef09b5ec20d.pdf



.


Documentation:


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
        · Copy Returned Address (your new Swap!)

To enter in details of your purchased contract:

      Swap - At address and enter the newly created Swap contract (e.g. 0x35d6a51eee77422820dcc7c51ab9148899a24daf  ) (note no quotation)
      · enter margin value (e.g. 100 eth)
      
      To calculate the date, you will need convert the date to hex.  Say you wanted July 20th 2017 to be the start date and July 27th 2017 to be the end date.  Go to a string to hex converter (https://codebeautify.org/string-hex-converter) and type in the firsts date in the YYYYMMDD format.  20170720  and get the result (3230313730373230).  Add a 0x to the front, and this is your start date.  Do this for the end Date as well.
      
      · Swap.createContract (ECP,margin,margin2,notional,long,startDate,endDate,cancellable) - 
          (e.g. true,100, 100, 1000, true, 0x3230313730373230, 0x3230313730373237)

      Your swap is now created!  Now you need a counterpary.  To incentivize counterparties, reduce Margin2 relative to margin

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
            var account1= "0xE5078b80b08bD7036fc0f7973f667b6aa.......";
            var key1 = new Buffer('........................', 'hex');
            var account2 = "0x939DD3E2DE8f472573364B3df1337857E7......"
            var key2 = new Buffer('.....................................', 'hex');

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
            var gasPriceHex = web3.toHex(21000000000);
            var rawTx = {
                nonce: nonceHex,
                gasPrice: gasPriceHex, 
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
            var payloadData = solidityFunction.toPayload([]).data;
            var rawTx = {
                nonce: nonceHex,
                gasPrice: gasPriceHex, //this is a hack to get around issues on Ropsten via Infura
                gasLimit: gasLimitHex,
                to:contractAddress,
                data: payloadData,
                chainId:3
            };
            
            var solidityFunction = new SolidityFunction('', _.find(abi, { name: 'PaySwap' }), '');
            var payloadData = solidityFunction.toPayload([]).data;
            var rawTx = {
                nonce: nonceHex,
                gasPrice: gasPriceHex, //this is a hack to get around issues on Ropsten via Infura
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
