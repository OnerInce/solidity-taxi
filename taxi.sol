pragma solidity >=0.7.0 <0.8.0;


contract TaxiSharing{
    
    uint JOIN_FEE = 5 ether;
    uint EXPENSE = 10 ether;
    
    address public manager;
    address payable public carDealer = address(0);
    address payable taxiDriver = address(0);
    address payable proposed_driver = address(0);
    address payable firedDriver = address(0);
    
    uint driver_account = 0;
    uint driver_salary = 0;
    uint proposed_salary = 0;
    int owned_car_id = 0;
    uint driver_approve = 0;
    uint driver_last_payment = 0;
    uint parti_last_payment = 0;
    uint expenseLastPayment = 0;
    uint contractBalance = 0;
    
    constructor() {
        manager = msg.sender;
    }
    
    struct Participant {
        address payable wallet;
        uint parti_balance;
    }
    
    Participant[] participants;
    
    struct CarPropose {
        int car_id;
        uint car_price;
        uint time_limit;
        uint approve_state;
        uint parti_balance;
        uint propose_time;
        bool is_active;
    }
        
    function seeBalances() public view returns (uint, uint){
        return (contractBalance, participants[0].parti_balance);
    }
    
    function seeContractWallet() public view returns (uint){
        return address(this).balance;
    }
    
    CarPropose currentOffer;
    
    modifier checkParti {
        require(isParticipant(msg.sender),
        "Not authorized. Only participants can call this function"
        );
        _;
    }
    
    modifier checkManager {
        require(msg.sender == manager,
        "Not authorized. Only manager can call this function"
        );
        _;
    }
    
    modifier checkDealer {
        require(msg.sender == carDealer,
        "Not authorized. Only car dealer can call this function"
        );
        _;
    }
    
    modifier checkDriver {
        require(msg.sender == taxiDriver || msg.sender == firedDriver,
        "Not authorized. Only driver can call this function"
        );
        _;
    }
    
    modifier driverPayCheck {
        if (driver_last_payment != 0) {
            require(block.timestamp - driver_last_payment > 30 days,
            "Wait for the payday"
            );
        }
        _;
    }
    
    modifier partiPayCheck {
        if (parti_last_payment != 0) {
            require(block.timestamp - parti_last_payment > 180 days,
            "Wait for the payday"
            );
        }
        _;
    }
    
    modifier expenseCheck {
        if (expenseLastPayment != 0) {
            require(block.timestamp - expenseLastPayment > 180 days,
            "You can only pay once in 6 months"
            );
        }
        _;
    }

    mapping(address => uint) public ParticipantWallets;
    mapping(address => bool) public isParticipantMap;
    mapping(address => bool) public votes;
    mapping(address => bool) public driver_vote;
    
    
    function getOfferPrice() public view returns (uint){
        return currentOffer.car_price;
    }

    function setWallet(address payable _wallet) internal{
        isParticipantMap[_wallet] = true;
    }
    
    function updateWalletMap(address payable parti_address) internal{
        ParticipantWallets[parti_address] = parti_address.balance;
    }

    function isParticipant(address payable _wallet) public view returns (bool){
        return isParticipantMap[_wallet];
    }
    
    function join() public payable {
        
        if (participants.length == 9)
            revert("No room for new participant");
            
        if (msg.value != JOIN_FEE)
            revert("Please pay the correct join fee");
            
        setWallet(msg.sender);
        updateWalletMap(msg.sender);
        
        Participant memory newParti;
        newParti.wallet = msg.sender;
        newParti.parti_balance = 0;
        participants.push(newParti);
        
    }
    
    function SetCarDealer(address payable dealer_wallet) public checkManager {
        carDealer = dealer_wallet;
    }

    function CarProposeToBusiness(int car, uint price, uint valid_seconds) public checkDealer{
        
        if (currentOffer.is_active == true)
            revert("There is already an active offer");
        
        currentOffer.is_active = true;
        currentOffer.car_id = car;
        currentOffer.car_price = price;
        currentOffer.time_limit = valid_seconds;
        currentOffer.approve_state = 0;
        currentOffer.propose_time = block.timestamp;
        
    }
    
    function ApprovePurchaseCar() public checkParti{
        if (currentOffer.is_active == false)
            revert("There is no offer to approve");
        
        if (votes[msg.sender])
            revert("You have already voted");
        
        votes[msg.sender] = true;
        currentOffer.approve_state += 1;
    }
    
    function PurchaseCar() public checkManager{
        if (currentOffer.car_id == 0)
            revert("There is no car to purchase");
            
        if (currentOffer.propose_time + currentOffer.time_limit < block.timestamp)
            revert("Can not purchase the car. Time limit exceeded.");  
            
        if (currentOffer.approve_state < participants.length / 2)
            revert("Can not approve the purchase since majority is not approved");
        
        for(uint8 i = 0; i < participants.length; i++){
            address addr = participants[i].wallet;
            votes[addr] = false;
        }
        
        carDealer.transfer(currentOffer.car_price * 1 ether);
        contractBalance -= currentOffer.car_price;
        
        currentOffer.is_active = false;
        owned_car_id = currentOffer.car_id;
        
    }
    
    function RepurchaseCarPropose(uint price, uint valid_seconds) public checkDealer{
        
        currentOffer.car_id = owned_car_id;
        currentOffer.car_price = price;
        currentOffer.time_limit = valid_seconds;
        currentOffer.approve_state = 0;
        currentOffer.propose_time = block.timestamp;
        currentOffer.is_active = true;
    }
    
    function ApproveSellProposal() public checkParti{
        
        if (currentOffer.is_active == false)
            revert("There is no offer to approve");
        
        if (votes[msg.sender])
            revert("You have already voted");
        
        votes[msg.sender] = true;
        currentOffer.approve_state += 1;
    }
    
    function Repurchasecar() payable public checkDealer{

        if (currentOffer.car_id == 0)
            revert("There is no offer to approve");
            
        if ((block.timestamp + currentOffer.time_limit) < currentOffer.propose_time)
            revert("Can not repurchase the car. Time limit exceeded.");  
            
        if (currentOffer.approve_state < participants.length / 2)
            revert("Can not approve the repurchase since majority is not approved");
            
        if (msg.value != currentOffer.car_price * 1 ether)
            revert("Please pay the correct amount of money");
            
        for(uint8 i = 0; i < participants.length; i++){
            address addr = participants[i].wallet;
            votes[addr] = false;
        }
        
        currentOffer.is_active = false;
        owned_car_id = 0;
        contractBalance += msg.value;
        
    }
    
    function ProposeDriver(address payable driver, uint salary) public checkManager{
        
        proposed_driver = driver;
        proposed_salary = salary;
    }
    
    function ApproveDriver() public checkParti{
        
        if (proposed_driver == address(0))
            revert("There is no driver to approve");
        
        if (driver_vote[msg.sender])
            revert("You have already voted");
        
        driver_vote[msg.sender] = true;
        driver_approve += 1;
    }
    
    function SetDriver() public checkManager{
        if (proposed_driver == address(0))
            revert("There is no driver to hire");
            
        if (driver_approve == 0 || driver_approve < participants.length / 2)
            revert("Can not approve the hire since majority is not approved");
        
        for(uint8 i = 0; i < participants.length; i++){
            address addr = participants[i].wallet;
            driver_vote[addr] = false;
        }
        
        taxiDriver = proposed_driver;
        driver_salary = proposed_salary;
        
        proposed_driver = address(0);
        proposed_salary = 0;
        
    }
    
    function FireDriver() public checkManager{
        
        driver_account += driver_salary;
        contractBalance = contractBalance - (driver_salary * 1 ether);
        
        firedDriver = taxiDriver;
        taxiDriver = address(0);
        driver_salary = 0;
       
    }
    
    function PayTaxiCharge() public payable{
        if (owned_car_id == 0)
            revert("You can not service to customers because you do not have a taxi");
            
        if (taxiDriver == address(0))
            revert("You can not service to customers because you do not have a driver");
        
        if (msg.value == 0)
            revert("Please pay the fee");
            
        contractBalance += msg.value;
    }
    
    function ReleaseSalary() public checkManager driverPayCheck{
        
        if (taxiDriver == address(0)){
            revert("No driver to pay. Hire a driver first.");
        }
        
        driver_last_payment = block.timestamp;
        driver_account += driver_salary;
        
        contractBalance = contractBalance - driver_salary * 1 ether;
    }
    
    function GetSalary() public checkDriver {
        if (driver_account == 0){
            revert("No amount to pay.");
        }
        
        if (firedDriver != address(0)){
            firedDriver.transfer(driver_account * 1 ether);
            firedDriver = address(0);
        }
        else
            taxiDriver.transfer(driver_account * 1 ether);
            
        driver_account = 0;
    }
    
    function PayCarExpenses() public checkManager expenseCheck{
        
        carDealer.transfer(EXPENSE);
        contractBalance -= EXPENSE;
        
        expenseLastPayment = block.timestamp;
    
    }
    
    function PayDividend() public checkManager partiPayCheck{
        
        uint amount = contractBalance / participants.length;
        
        for(uint8 i = 0; i < participants.length; i++){
            participants[i].parti_balance += amount;
        }
        
        contractBalance = 0;
        parti_last_payment = block.timestamp;
    }
    
    function GetDividend() public checkParti {
        
        for(uint8 i = 0; i < participants.length; i++){
            if (address(participants[i].wallet) == msg.sender)
                msg.sender.transfer(participants[i].parti_balance);
                participants[i].parti_balance = 0;
        }
    }
    
}
