#[starknet::interface]
trait IBookstore<TContractState> {
    fn add_book(ref self: TContractState, title: felt252, author: felt252);
    fn get_book(self: @TContractState, id: felt252) -> (felt252, felt252);
    fn update_book(ref self: TContractState, id: felt252, title: felt252, author: felt252);
    fn list_books(self: @TContractState) -> Array<(felt252, felt252)>;
}

#[starknet::contract]
mod Bookstore {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        books: Array<(felt252, felt252)>, // Array of tuples (title, author)
    }

    #[abi(embed_v0)]
    impl BookstoreImpl of super::IBookstore<ContractState> {
        fn add_book(ref self: ContractState, title: felt252, author: felt252) {
            let new_id = self.books.length(); // Use length as ID
            self.books.append((title, author));
        }

        fn get_book(self: @ContractState, id: felt252) -> (felt252, felt252) {
            return self.books.at(id);
        }

        fn update_book(ref self: ContractState, id: felt252, title: felt252, author: felt252) {
            if id < self.books.length() {
                self.books[id] = (title, author); // Update book details
            }
        }

        fn list_books(self: @ContractState) -> Array<(felt252, felt252)> {
            return self.books; // Return all books
        }
    }
}
