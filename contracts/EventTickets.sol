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
    modifier onlyOwner () {
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
    function getBuyerTicketCount(address buyer)
        public
        view
        returns(uint buyerTicketCount)
    {
        buyerTicketCount = myEvent.buyerTicketCount[buyer];
        return(buyerTicketCount);
    }

    // @dev Allows someone to purchase tickets for the event
    // @param Number of tickets to be purchased
    function buyTickets(uint ticketsPurchased)
        public
        payable
    {
        require(myEvent.isOpen = true, "Ticket sales have closed for this event");
        require(msg.value >= TICKET_PRICE * ticketsPurchased, "Insufficient funds were sent with order");
        require(myEvent.totalTickets >= ticketsPurchased, "Not enough tickets left to fill your order");
        myEvent.buyerTicketCount[msg.sender] = ticketsPurchased;
        myEvent.totalTickets -= ticketsPurchased;
        emit LogBuyTickets(msg.sender, ticketsPurchased);
        if (msg.value >= TICKET_PRICE * ticketsPurchased) {
            msg.sender.transfer(msg.value - (TICKET_PRICE * ticketsPurchased));
            emit LogGetRefund(msg.sender, msg.value - (TICKET_PRICE * ticketsPurchased));
        }
    }
}

    //function getRefund()

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
