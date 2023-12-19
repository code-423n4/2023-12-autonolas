// SPDX-License-Identifier: Apache-2.0

// Disclaimer: This library provides a way for Solidity to interact with Solana's SPL-Token. Although it is production ready,
// it has not been audited for security, so use it at your own risk.

import 'solana';

library SplToken {
	address constant tokenProgramId = address"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA";
	enum TokenInstruction {
		InitializeMint, // 0
		InitializeAccount, // 1
		InitializeMultisig, // 2
		Transfer, // 3
		Approve, // 4
		Revoke, // 5
		SetAuthority, // 6
		MintTo, // 7
		Burn, // 8
		CloseAccount, // 9
		FreezeAccount, // 10
		ThawAccount, // 11
		TransferChecked, // 12
		ApproveChecked, // 13
		MintToChecked, // 14
		BurnChecked, // 15
		InitializeAccount2, // 16
		SyncNative, // 17
		InitializeAccount3, // 18
		InitializeMultisig2, // 19
		InitializeMint2, // 20
		GetAccountDataSize, // 21
		InitializeImmutableOwner, // 22
		AmountToUiAmount, // 23
		UiAmountToAmount, // 24
		InitializeMintCloseAuthority, // 25
		TransferFeeExtension, // 26
		ConfidentialTransferExtension, // 27
		DefaultAccountStateExtension, // 28
		Reallocate, // 29
		MemoTransferExtension, // 30
		CreateNativeMint // 31
	}

	/// @dev Mint new tokens. The transaction should be signed by the PDA mint authority keypair
	/// @param mint the account of the mint
	/// @param account the token account where the minted tokens should go
	/// @param authority the public key of the mint authority
	/// @param amount the amount of tokens to mint
	/// @param seed PDA seed
	/// @param bump PDA bump
	function pda_mint_to(address mint, address account, address authority, uint64 amount, bytes seed, bytes bump) internal {
		bytes instr = new bytes(9);
		instr[0] = uint8(TokenInstruction.MintTo);
		instr.writeUint64LE(amount, 1);

		AccountMeta[3] metas = [
			AccountMeta({pubkey: mint, is_writable: true, is_signer: false}),
			AccountMeta({pubkey: account, is_writable: true, is_signer: false}),
			AccountMeta({pubkey: authority, is_writable: false, is_signer: true})
		];

		tokenProgramId.call{accounts: metas, seeds: [[seed, bump]]}(instr);
	}

	/// @dev Transfer @amount token from @from to @to. The transaction should be signed by the owner
	/// keypair of the from account.
	/// @param from the account to transfer tokens from
	/// @param to the account to transfer tokens to
	/// @param owner the publickey of the from account owner keypair
	/// @param amount the amount to transfer
	function transfer(address from, address to, address owner, uint64 amount) internal {
		bytes instr = new bytes(9);
		instr[0] = uint8(TokenInstruction.Transfer);
		instr.writeUint64LE(amount, 1);

		AccountMeta[3] metas = [
			AccountMeta({pubkey: from, is_writable: true, is_signer: false}),
			AccountMeta({pubkey: to, is_writable: true, is_signer: false}),
			AccountMeta({pubkey: owner, is_writable: false, is_signer: true})
		];

		tokenProgramId.call{accounts: metas}(instr);
	}

	/// @dev Burn @amount tokens in account. This transaction should be signed by the PDA.
	/// @param account the acount for which tokens should be burned
	/// @param mint the mint for this token
	/// @param owner the publickey of the account owner keypair
	/// @param amount the amount to burn
	/// @param seed PDA seed
	/// @param bump PDA bump
	function pda_burn(address account, address mint, address owner, uint64 amount, bytes seed, bytes bump) internal {
		bytes instr = new bytes(9);
		instr[0] = uint8(TokenInstruction.Burn);
		instr.writeUint64LE(amount, 1);

		AccountMeta[3] metas = [
			AccountMeta({pubkey: account, is_writable: true, is_signer: false}),
			AccountMeta({pubkey: mint, is_writable: true, is_signer: false}),
			AccountMeta({pubkey: owner, is_writable: false, is_signer: true})
		];

		tokenProgramId.call{accounts: metas, seeds: [[seed, bump]]}(instr);
	}

	/// @dev Get the total supply for the mint, i.e. the total amount in circulation
	/// @param account The AccountInfo struct for the mint account
	function total_supply(AccountInfo account) internal view returns (uint64) {
		return account.data.readUint64LE(36);
	}

	/// @dev Get the balance for an account.
	/// @param account the struct AccountInfo whose account balance we want to retrieve
	function get_balance(AccountInfo account) internal view returns (uint64) {
		return account.data.readUint64LE(64);
	}
}
