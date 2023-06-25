# Queue Offer

This smart contract implements a queue data structure called `OfferQueue` that allows efficient insertion and removal of items from both ends of the sequence. It is used to implement First-In-First-Out (FIFO) queues. The code is inspired by OpenZeppelin Contracts (last updated v4.6.0).

## Usage

To use the `OfferQueue` data structure, follow these steps:

1. Import the necessary library:
   ```solidity
   import "openzeppelin-contracts/utils/math/SafeCast.sol";
   ```

2. Define an instance of the `OfferQueue` struct:
   ```solidity
   Queue.OfferQueue queue;
   ```

3. Perform operations on the queue using the available functions.

## Operations

The `OfferQueue` struct provides the following functions for working with the queue:

### `createQueueOffer`

Inserts an item at the end of the queue.

```solidity
function createQueueOffer(OfferQueue storage queue, Offer memory offer ) internal
```

### `front`

Returns the item at the beginning of the queue.

```solidity
function front(OfferQueue storage queue) internal view returns (Offer memory value)
```

### `back`

Returns the item at the end of the queue.

```solidity
function back(OfferQueue storage queue) internal view returns (Offer memory value)
```

### `at`

Returns the item at a specified position in the queue.

```solidity
function at(OfferQueue storage queue, uint256 index) internal view returns (Offer memory value)
```

### `clear`

Resets the queue back to being empty.

```solidity
function clear(OfferQueue storage queue) internal
```

### `length`

Returns the number of items in the queue.

```solidity
function length(OfferQueue storage queue) public view returns (uint256)
```

### `isEmpty`

Returns true if the queue is empty.

```solidity
function isEmpty(OfferQueue storage queue) public view returns (bool)
```

### `getQueue`

Returns an array containing all the offers in the queue.

```solidity
function getQueue(OfferQueue storage queue) public view returns (Offer[] memory)
```

## Custom Types

The `OfferQueue` struct contains the following custom type:

```solidity
struct Offer {
    uint creatorId;
    address token;
    uint256 amount;
    uint256 timestamp;
    address owner;
}
```

This struct represents an offer and contains the following fields:

- `creatorId`: The ID of the offer creator.
- `token`: The address of the token associated with the offer.
- `amount`: The amount of the offer.
- `timestamp`: The timestamp of the offer creation.
- `owner`: The address of the offer owner.

## Events

The `OfferQueue` struct emits the following events:

- `OfferCreated`: Fired when a new offer is created.
- `OfferTaken`: Fired when an offer is taken from the queue.
- `OfferModified`: Fired when an offer in the queue is modified.

## Notes

- The `OfferQueue` data structure can only be used in storage and not in memory.
- All operations on the queue have a constant time complexity of O(1).
- When using the `clear` function, note that the current items are left behind in storage, which may affect potential gas refunds.

_This library was made available since version 4.6 of OpenZeppelin Contracts._
