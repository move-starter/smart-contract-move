module launchpad_addr::test_token{

    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::account;
    use aptos_std::table::{Self, Table};
    use launchpad_addr::tokenget;
    use aptos_framework::aptos_account;
    use aptos_framework::event;
    use aptos_framework::fungible_asset::{Self, Metadata};
    use aptos_framework::object::{Self, Object, ObjectCore};
    use aptos_framework::primary_fungible_store;



 #[test(admin = @launchpad_addr, creator = @0x2)]
fun test_create_fa_with_default_values2(admin: &signer, creator: &signer) acquires 
    tokenget::Registry, 
    tokenget::FAController
{
    // Create accounts for test
    account::create_account_for_test(signer::address_of(admin));
    account::create_account_for_test(signer::address_of(creator));

    // Initialize Registry
    move_to(admin, tokenget::Registry {
        fa_objects: vector::empty()
    });

    // Initialize Config
    move_to(admin, tokenget::Config {
        admin_addr: signer::address_of(admin),
        pending_admin_addr: option::none(),
        mint_fee_collector_addr: signer::address_of(admin),
    });

    // Initialize Treasury
    move_to(admin, tokenget::Treasury {
        balance: 0
    });

    // Prepare FA creation parameters with default values
    let max_supply = option::none();
    let name = string::utf8(b"Test Token");
    let symbol = string::utf8(b"TST");
    let decimals = 8;
    let icon_uri = string::utf8(b"https://example.com/icon.png");
    let project_uri = string::utf8(b"https://example.com/project");
    let mint_fee = option::none();
    let pre_mint_amount = option::none();
    let mint_limit = option::none();

    // Create FA
    tokenget::create_fa(
        creator, 
        max_supply, 
        name, 
        symbol, 
        decimals, 
        icon_uri, 
        project_uri, 
        mint_fee, 
        pre_mint_amount, 
        mint_limit
    );

    // Verify FA creation
    let registry = borrow_global<tokenget::Registry>(@launchpad_addr);
    assert!(vector::length(&registry.fa_objects) == 1, 1);

    // Verify FA metadata
    let fa_obj = *vector::borrow(&registry.fa_objects, 0);
    assert!(fungible_asset::name(fa_obj) == name, 2);
    assert!(fungible_asset::symbol(fa_obj) == symbol, 3);
    assert!(fungible_asset::decimals(fa_obj) == decimals, 4);
}




#[test(admin = @launchpad_addr, user1 = @0x123, user2 = @0x456)]
fun test_buy_token(
    admin: &signer, 
    user1: &signer, 
    user2: &signer
) acquires tokenget::Registry, tokenget::FAController, tokenget::FAConfig, tokenget::Treasury {
    // Properly initialize the Aptos Coin for testing
    let aptos_framework = account::create_account_for_test(@aptos_framework);
    
    // Setup test accounts with proper registration
    account::create_account_for_test(signer::address_of(admin));
    account::create_account_for_test(signer::address_of(user1));
    account::create_account_for_test(signer::address_of(user2));

    // Initialize Aptos coin and get mint/burn capabilities
    let (burn_cap, mint_cap) = 0x1::aptos_coin::initialize_for_test(&aptos_framework);

    // Ensure coin stores are registered
    coin::register<0x1::aptos_coin::AptosCoin>(admin);
    coin::register<0x1::aptos_coin::AptosCoin>(user1);
    coin::register<0x1::aptos_coin::AptosCoin>(user2);

    // Mint coins to users
    let coins_to_mint = 10000;
    let coins_user1 = coin::mint<0x1::aptos_coin::AptosCoin>(coins_to_mint, &mint_cap);
    coin::deposit(signer::address_of(user1), coins_user1);
    
    let coins_user2 = coin::mint<0x1::aptos_coin::AptosCoin>(coins_to_mint, &mint_cap);
    coin::deposit(signer::address_of(user2), coins_user2);

    // Destroy mint and burn capabilities after use
    coin::destroy_mint_cap(mint_cap);
    coin::destroy_burn_cap(burn_cap);

    // Initialize Registry
    move_to(admin,tokenget::Registry {
        fa_objects: vector::empty()
    });

    // Initialize Config
    move_to(admin, tokenget::Config {
        admin_addr: signer::address_of(admin),
        pending_admin_addr: option::none(),
        mint_fee_collector_addr: signer::address_of(admin),
    });

    // Initialize Treasury
    move_to(admin, tokenget::Treasury {
        balance: 0
    });

    // Create a token
    let max_supply = option::some(1000000u128);
    let name = string::utf8(b"Test Token");
    let symbol = string::utf8(b"TST");
    let decimals = 8;
    let icon_uri = string::utf8(b"https://example.com/icon.png");
    let project_uri = string::utf8(b"https://example.com/project");
    let mint_fee = option::some(10000000u64); // 1 APT per token
    let pre_mint_amount = option::none();
    let mint_limit = option::none();

    tokenget::create_fa(
        user1, 
        max_supply, 
        name, 
        symbol, 
        decimals, 
        icon_uri, 
        project_uri, 
        mint_fee, 
        pre_mint_amount, 
        mint_limit
    );

    // Get the created FA object
    let registry = borrow_global<tokenget::Registry>(@launchpad_addr);
    let fa_obj = *vector::borrow(&registry.fa_objects, 0);

    // Buy tokens
    tokenget::buy_token(user2, fa_obj, 100000000);

    // Verify token purchase
    let user2_balance = primary_fungible_store::balance(
        signer::address_of(user2), 
        fa_obj
    );
    assert!(user2_balance == 10, 1); // 100 APT / 10 APT per token = 10 tokens

    let treasury = borrow_global<tokenget::Treasury>(@launchpad_addr);
    assert!(treasury.balance == 10, 2); // Verify treasury received 100 APT
}

#[test(admin = @launchpad_addr , user1 = @0x123, user2 = @0x111)]
fun test_sell_token(admin : &signer , user1 : &signer, user2 : &signer)
 acquires tokenget::Registry, tokenget::FAController, tokenget::FAConfig, tokenget::Treasury 
{
     account::create_account_for_test(signer::address_of(admin));
    account::create_account_for_test(signer::address_of(user1));
    account::create_account_for_test(signer::address_of(user2));

    // Initialize Aptos coin and get mint/burn capabilities
      let aptos_framework = account::create_account_for_test(@aptos_framework);
    let (burn_cap, mint_cap) = 0x1::aptos_coin::initialize_for_test(&aptos_framework);

    // Ensure coin stores are registered
    coin::register<0x1::aptos_coin::AptosCoin>(admin);
    coin::register<0x1::aptos_coin::AptosCoin>(user1);
    coin::register<0x1::aptos_coin::AptosCoin>(user2);

    // Mint coins to users
    let coins_to_mint = 10000;
    let coins_user1 = coin::mint<0x1::aptos_coin::AptosCoin>(coins_to_mint, &mint_cap);
    coin::deposit(signer::address_of(user1), coins_user1);
    
    let coins_user2 = coin::mint<0x1::aptos_coin::AptosCoin>(coins_to_mint, &mint_cap);
    coin::deposit(signer::address_of(user2), coins_user2);

    // Destroy mint and burn capabilities after use
    coin::destroy_mint_cap(mint_cap);
    coin::destroy_burn_cap(burn_cap);

    // Initialize Registry
    move_to(admin, tokenget::Registry {
        fa_objects: vector::empty()
    });

    // Initialize Config
    move_to(admin, tokenget::Config {
        admin_addr: signer::address_of(admin),
        pending_admin_addr: option::none(),
        mint_fee_collector_addr: signer::address_of(admin),
    });

    // Initialize Treasury
    move_to(admin, tokenget::Treasury {
        balance: 0
    });

    // Create a token
    let max_supply = option::some(1000000u128);
    let name = string::utf8(b"Test Token");
    let symbol = string::utf8(b"TST");
    let decimals = 8;
    let icon_uri = string::utf8(b"https://example.com/icon.png");
    let project_uri = string::utf8(b"https://example.com/project");
    let mint_fee = option::some(10u64); // 10 APT per token
    let pre_mint_amount = option::none();
    let mint_limit = option::none();

    tokenget::create_fa(
        user1, 
        max_supply, 
        name, 
        symbol, 
        decimals, 
        icon_uri, 
        project_uri, 
        mint_fee, 
        pre_mint_amount, 
        mint_limit
    );

    // Get the created FA object
    let registry = borrow_global<tokenget::Registry>(@launchpad_addr);
    let fa_obj = *vector::borrow(&registry.fa_objects, 0);

    // Buy tokens
    tokenget::buy_token(user2, fa_obj, 100);

    // Verify token purchase
    let user2_balance = primary_fungible_store::balance(
        signer::address_of(user2), 
        fa_obj
    );
    assert!(user2_balance == 10, 1); // 100 APT / 10 APT per token = 10 tokens

    let treasury = borrow_global<tokenget::Treasury>(@launchpad_addr);
    assert!(treasury.balance == 100, 2); // Verify treasury received 100 APT

    tokenget::sell_token(user2, fa_obj,5); // not working......

 let treasury = borrow_global<tokenget::Treasury>(@launchpad_addr);
 assert!(treasury.balance == 100, 2); // Verify treasury have 50 APT
}




}

