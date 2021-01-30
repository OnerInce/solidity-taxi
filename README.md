<p align="center">
  <a href="" rel="noopener">
 <img width=684px height=245px src="banner.jpg" alt="Banner"></a>
</p>

<h3 align="center">Taxi Sharing Ethereum Smart Contract</h3>

---

Aim of this project is to create a smart contract that handles a common asset and distribution of income generated from this asset in certain time intervals. The common asset is a taxi. Imagine a group of people in the same neighborhood who would like to invest into an asset. They can't invest individually because each person has a very small amount of money, thus they can combine their holdings together to invest into a bigger and more profitable investment. They decided to combine their money and buy a car which will be used as a taxi and the profit will be shared among participants every month. However, one problem is that they have no trust in each other. To make this investment work, smart contract comes into play. The contract is written with Solidity language and will run on Ethereum network.

## 📝 Table of Contents
+ [Variables](#variables)
+ [Functions](#functions)
+ [Process](#process)
+ [Notes](#notes)

## :electric_plug: Variables <a name = "variables"></a>

**Participants:** maximum of 9, each participant identified with an address and has a balance

**Manager:** a manager that is decided offline who creates the contract initially.

**Taxi Driver:** 1 taxi driver and salary

**Car Dealer:** An identity to buy/sell car, also handles maintenance and tax

**Contract balance:** Current total money in the contract that has not been distributed

**Fixed expenses:** Every 6 months car needs to go to Car Dealer for maintenance and taxes needs to be paid, total amount for maintenance and tax is fixed and 10 Ether for every 6 months.

**Participation fee:** An amount that participants needs to pay for entering the taxi business.

**Owned Car:** identified with a 32 digit number, CarID

**Proposed Car:** Car proposal proposed by the CarDealer, Holds {CarID, price, offer valid time and approval state } information.

**Proposed Repurchase:** Car repurchase proposal proposed by the CarDealer, Holds {CarID (the owned car id), price, offer valid time, and approval state} information.

## :microphone: Functions <a name = "functions"></a>

**Constructor:** Called by owner of the contract and sets the manager and other initial values for state variables

**Join:** Public, Called by participants, Participants needs to pay the participation fee set in the contract to be a member in the taxi investment

**SetCarDealer:** Only Manager can call this function, Sets the CarDealer’s address

**CarProposeToBusiness:** Only CarDealer can call this, sets Proposed Car values, such as CarID, price, offer valid time and approval state (to 0)

**ApprovePurchaseCar:** Participants can call this function, approves the Proposed Purchase with incrementing the approval state. Each participant can increment once.

**PurchaseCar:** Only Manager can call this function, sends the CarDealer the price of the proposed car if the offer valid time is not passed yet and approval state is approved by more than half of the participants.

**RepurchaseCarPropose:** Only CarDealer can call this, sets Proposed Purchase values, such as CarID, price, offer valid time and
approval state (to 0)

**ApproveSellProposal:** Participants can call this function, approves the Proposed Sell with incrementing the approval state. Each participant can increment once.

**Repurchasecar:** Only CarDealer can call this function, sends the proposed car price to contract if the offer valid time is not passed yet and approval state is approved by more than half of the participants.

**ProposeDriver:** Only Manager can call this function, sets driver address, and salary.

**ApproveDriver:** Participants can call this function, approves the Proposed Driver with incrementing the approval state. Each participant can increment once.

**SetDriver:** Only Manager can call this function, sets the Driver info if approval state is approved by more than half of the participants.

**FireDriver:** Only Manager can call this function, gives the full month of salary to current driver’s account.

**PayTaxiCharge:** Public, customers who use the taxi pays their ticket through this function. Charge is sent to contract.

**ReleaseSalary:** Only Manager can call this function, releases the salary of the Driver to his/her account monthly. 

**GetSalary:** Only Driver can call this function, if there is any money in Driver’s account, it will be send to his/her address

**PayCarExpenses:** Only Manager can call this function, sends the CarDealer the price of the expenses every 6 month.

**PayDividend:** Only Manager can call this function, calculates the total profit after expenses and Driver salaries, calculates the profit per participant and releases this amount to participants in every 6 month. 

**GetDividend:** Only Participants can call this function, if there is any money in participants’ account, it will be send to his/her address

## :mag_right: Process <a name = "process"></a>

First dealer calls “CarProposeToBusiness”. Participants vote to approve the proposed car through “ApprovePurchaseCar”. If the approval state is approved by more than half of the participants then manager calls “PurchaseCar”. To sell the car, manager and dealer talks out side of the system in person. If the dealer agrees to buy the car he/she calls the “RepurchaseCarPropose” function with intended price for the car. Participants vote to sell through “ApproveSellProposal”. If majority approves, car dealer calls “Repurchasecar”.

## :grey_question: Notes <a name = "notes"></a>

- When deploying the contract, Remix IDE giving an error "out of gas. out of gas The transaction ran out of gas". Setting Gas limit to a higher value e.g. 9000000 solving the problem.

- All payable functions are only accepting ether

- For the functions which require a time variable as a parameter (CarProposeToBusiness, RepurchaseCarPropose), time must be given as seconds.
