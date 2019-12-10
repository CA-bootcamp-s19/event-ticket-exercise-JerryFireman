pragma solidity ^0.5.0;

// @dev The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
contract EventTicketsV2 {

    // @dev Owner of the contract
    address payable public owner;

    // @dev Sets owner to the address that instantiated the contract
    constructor() public {
        owner = msg.sender;
    }

    uint   PRICE_TICKET = 100 wei;

    // @dev Track event ID numbers
    uint public idGenerator;

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

    // @dev Keeps track of events
    mapping (uint => Event) events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    // @dev Throws error if the msg.sender is not the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner, "Message sender is not owner of contract");
        _;
    }

    function addEvent(string memory _description, string memory _website, uint _totalTickets)
        public
        onlyOwner
        returns (uint)
    {
        owner = msg.sender;
        Event storage newEvent = events[idGenerator];
        newEvent.description = _description;
        newEvent.website = _website;
        newEvent.totalTickets = _totalTickets;
        newEvent.isOpen = true;
        idGenerator++;
        return idGenerator - 1;
    }

    // @dev Returns the details of event
    // @param ID of the event
    function readEvent(uint _eventID)
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        description = events[_eventID].description;
        website = events[_eventID].website;
        totalTickets = events[_eventID].totalTickets;
        sales = events[_eventID].sales;
        isOpen = events[_eventID].isOpen;
        return(description, website, totalTickets, sales, isOpen);
    }

    // @dev Allows someone to purchase tickets for any event
    // @param ID of the event
    // @param Number of tickets to be purchased
    function buyTickets(uint _eventID, uint _ticketsPurchased)
        public
        payable
    {
        require(events[_eventID].isOpen = true, "Ticket sales have closed for this event");
        require(msg.value >= PRICE_TICKET * _ticketsPurchased, "Insufficient funds were sent with order");
        require((events[_eventID].totalTickets - events[_eventID].sales) >= _ticketsPurchased, "Not enough tickets left to fill your order");
        events[_eventID].buyerTicketCount[msg.sender] += _ticketsPurchased;
        events[_eventID].sales += _ticketsPurchased;
        emit LogBuyTickets(msg.sender, _eventID, _ticketsPurchased);
        if (msg.value > PRICE_TICKET * _ticketsPurchased) {
            msg.sender.transfer(msg.value - (PRICE_TICKET * _ticketsPurchased));
            emit LogGetRefund(msg.sender, _eventID, msg.value - (PRICE_TICKET * _ticketsPurchased));
        }
    }

    // @dev Enables buyer to request refund for tickets they have ordered
    function getRefund(uint _eventID)
        public
    {
        require(events[_eventID].buyerTicketCount[msg.sender] > 0, "You haven't purchased tickets for this event");
        events[_eventID].totalTickets += events[_eventID].buyerTicketCount[msg.sender];
        msg.sender.transfer(events[_eventID].buyerTicketCount[msg.sender] * PRICE_TICKET);
        emit LogGetRefund(msg.sender, _eventID, events[_eventID].buyerTicketCount[msg.sender] * PRICE_TICKET);
        events[_eventID].buyerTicketCount[msg.sender] = 0;
        events[_eventID].sales -= events[_eventID].buyerTicketCount[msg.sender];
    }

    // @dev Returns the number of tickets that address has purchased
    // @param The event ID
    function getBuyerNumberTickets(uint _eventID)
        public
        view
        returns(uint buyerTicketCount)
    {
        buyerTicketCount = events[_eventID].buyerTicketCount[msg.sender];
        return(buyerTicketCount);
    }

    // @dev Closes ticket sales
    // @param The event ID
    function endSale(uint _eventID)
        public
        onlyOwner
    {
        events[_eventID].isOpen = false;
        emit LogEndSale(owner, events[_eventID].sales * PRICE_TICKET, _eventID);
        owner.transfer(events[_eventID].sales * PRICE_TICKET);
    }
}