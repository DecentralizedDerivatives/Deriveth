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




Mist Wallet:
