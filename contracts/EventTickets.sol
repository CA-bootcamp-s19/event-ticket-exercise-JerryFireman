pragma solidity ^0.5.0;

// The EventTickets contract keeps track of the details and ticket sales of one event.

contract EventTickets {

    // @dev Owner of the contract
    address payable public owner;

    // @dev Sets price of tickets for event
    uint TICKET_PRICE = 100 wei;

    // @dev Stores information about the event including ticket buyers
    // and how many tickets were purchased by each
    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyerTicketCount;
        bool isOpen;
    }

    Event myEvent;

    // @dev Provides information about the purchaser and the number of tickets purchased
    event LogBuyTickets(address, uint);

    // @dev Provides information about the refund requester and the number of tickets refunded
    event LogGetRefund(address, uint);

    // @dev Provides the contract owner address and the balance transferred to it when ticket sales conclude
    event LogEndSale(address, uint);

    // @dev Throws error if the msg.sender is not the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner, "Message sender is not owner of contract");
        _;
    }

    // @dev Sets owner to the address that instantiated the contract
    // @dev Sets the appropriate event details
    constructor(string memory _description, string memory _website, uint _totalTickets) public {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.website = _website;
        myEvent.totalTickets = _totalTickets;
        myEvent.sales = 0;
        myEvent.isOpen = true;
    }

    // @dev Returns the details of myEvent
    function readEvent()
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        description = myEvent.description;
        website = myEvent.website;
        totalTickets = myEvent.totalTickets;
        sales = myEvent.sales;
        isOpen = myEvent.isOpen;
        return(description, website, totalTickets, sales, isOpen);
    }

    // @dev Returns the number of tickets that address has purchased
    // @param Buyer's address
    function getBuyerTicketCount(address _buyer)
        public
        view
        returns(uint buyerTicketCount)
    {
        buyerTicketCount = myEvent.buyerTicketCount[_buyer];
        return(buyerTicketCount);
    }

    // @dev Allows someone to purchase tickets for the event
    // @param Number of tickets to be purchased
    function buyTickets(uint _ticketsPurchased)
        public
        payable
    {
        require(myEvent.isOpen = true, "Ticket sales have closed for this event");
        require(msg.value >= TICKET_PRICE * _ticketsPurchased, "Insufficient funds were sent with order");
        require((myEvent.totalTickets - myEvent.sales) >= _ticketsPurchased, "Not enough tickets left to fill your order");
        myEvent.buyerTicketCount[msg.sender] += _ticketsPurchased;
        myEvent.sales += _ticketsPurchased;
        emit LogBuyTickets(msg.sender, _ticketsPurchased);
        if (msg.value > TICKET_PRICE * _ticketsPurchased) {
            msg.sender.transfer(msg.value - (TICKET_PRICE * _ticketsPurchased));
            emit LogGetRefund(msg.sender, msg.value - (TICKET_PRICE * _ticketsPurchased));
        }
    }

    // @dev Enables buyer to request refund for tickets they have ordered
    function getRefund()
        public
    {
        require(myEvent.buyerTicketCount[msg.sender] > 0, "You haven't purchased tickets for this event");
        myEvent.totalTickets += myEvent.buyerTicketCount[msg.sender];
        msg.sender.transfer(myEvent.buyerTicketCount[msg.sender] * TICKET_PRICE);
        emit LogGetRefund(msg.sender, myEvent.buyerTicketCount[msg.sender] * TICKET_PRICE);
        myEvent.buyerTicketCount[msg.sender] = 0;
        myEvent.sales -= myEvent.buyerTicketCount[msg.sender];

    }

    // @dev Closes ticket sales
    function endSale()
        public
        onlyOwner
    {
        myEvent.isOpen = false;
        emit LogEndSale(owner, address(this).balance);
        owner.transfer(address(this).balance);
    }
}