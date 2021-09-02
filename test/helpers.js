export const EVM_Revert = 'VM Exception while processing transaction: revert'
export const ETHER_ADDRESS = '0x0000000000000000000000000000000000000000'

export const ether = (n) => {
	return new web3.utils.BN(
		web3.utils.toWei(n.toString(), 'ether') // not ether but we can use for convenience as ether has the same number of decimals
	)
}

// same as ether
export const tokens = (n) => ether(n)