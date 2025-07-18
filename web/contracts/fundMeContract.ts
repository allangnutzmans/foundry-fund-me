export const fundMeContract = {
    address: '0xc5928db46694bE32460f1719B43E54845d227bd6',
    abi: [
        {
          "type": "constructor",
          "inputs": [{ "name": "priceFeed", "type": "address", "internalType": "address" }],
          "stateMutability": "nonpayable"
        },
        { "type": "fallback", "stateMutability": "payable" },
        { "type": "receive", "stateMutability": "payable" },
        {
          "type": "function",
          "name": "MINIMUM_USD",
          "inputs": [],
          "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
          "stateMutability": "view"
        },
        { "type": "function", "name": "cheaperWithdraw", "inputs": [], "outputs": [], "stateMutability": "nonpayable" },
        { "type": "function", "name": "fund", "inputs": [], "outputs": [], "stateMutability": "payable" },
        {
          "type": "function",
          "name": "getAddressToAmountFunded",
          "inputs": [{ "name": "fundingAddress", "type": "address", "internalType": "address" }],
          "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
          "stateMutability": "view"
        },
        {
          "type": "function",
          "name": "getFunder",
          "inputs": [{ "name": "index", "type": "uint256", "internalType": "uint256" }],
          "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
          "stateMutability": "view"
        },
        {
          "type": "function",
          "name": "getOwner",
          "inputs": [],
          "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
          "stateMutability": "view"
        },
        {
          "type": "function",
          "name": "getPriceFeed",
          "inputs": [],
          "outputs": [{ "name": "", "type": "address", "internalType": "contract AggregatorV3Interface" }],
          "stateMutability": "view"
        },
        {
          "type": "function",
          "name": "getVersion",
          "inputs": [],
          "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
          "stateMutability": "view"
        },
        {
          "type": "function",
          "name": "s_addressToAmountFunded",
          "inputs": [{ "name": "", "type": "address", "internalType": "address" }],
          "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
          "stateMutability": "view"
        },
        {
          "type": "function",
          "name": "s_funders",
          "inputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
          "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
          "stateMutability": "view"
        },
        { "type": "function", "name": "withdraw", "inputs": [], "outputs": [], "stateMutability": "nonpayable" },
        { "type": "error", "name": "FundMe__NotOwner", "inputs": [] }
    ]
} as const