# What is ERC721A

## How does ERC721A save gas?

ERC721A saves gas in three ways:

1. **Batch minting:** ERC721A allows for batch minting of multiple NFTs in a single transaction. This can save a significant amount of gas, as each individual mint operation incurs a gas cost.
2. **Efficient storage:** ERC721A uses more efficient storage for token metadata. This reduces the amount of gas needed to read and write metadata, which can be a significant cost for operations such as transferring or listing NFTs.
3. **Reduced ownership updates:** ERC721A only updates the owner of an NFT once per batch mint operation. This can save gas, as each individual ownership update incurs a gas cost.

# Where does ERC721A add cost?

ERC721A adds some cost in two areas:

1. **Initial deployment:** The ERC721A contract is more complex than the ERC721 contract, so it requires more gas to deploy.
2. **Enumerable implementation:** The ERC721A contract includes an enumerable implementation, which allows for efficient iteration over all of the NFTs in a collection. However, this implementation can add some gas cost, especially for large collections.

# Why shouldn’t ERC721A enumerable’s implementation be used on-chain?

The ERC721A enumerable implementation should not be used on-chain for large collections because it can add a significant amount of gas cost. The implementation works by storing a mapping from token IDs to tokenURIs. This mapping can be large and expensive to store on-chain, especially for large collections. Additionally, the mapping needs to be updated every time a new token is minted or an existing token is transferred. This can also add a significant amount of gas cost.

A better approach is to use a decentralized storage solution, such as IPFS, to store the token metadata. This will reduce the gas cost of storing and updating the metadata, and it will also make the metadata more accessible to users.

