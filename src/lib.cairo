#[derive(Copy, Drop, Serde, starknet::Store)]
struct Student {
    name: felt252,
    grade: u8,
}

#[starknet::interface]
pub trait IClassroom<TContractState> {
    fn add_student(ref self: TContractState, student_id: felt252, name: felt252, grade: u8);
    fn update_student(ref self: TContractState, student_id: felt252, upgrade: u8);
    fn get_student(self: @TContractState, student_id: felt252) -> Student;
}

#[starknet::contract]
pub mod Classroom {
    use super::{Student, IClassroom};
    use core::starknet::{
        get_caller_address, ContractAddress,
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess}
    };

    #[storage]
    struct Storage {
        students: Map<felt252, Student>, //map student_id => student struct
        teacher: ContractAddress,
    }

    //event //communicates whatever is happening within smart contract with the outside world
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StudentAdded: StudentAdded,
    }

    #[derive(Drop, starknet::Event)]
    struct StudentAdded {
        name: felt252,
        student_id: felt252,
        grade: u8,
    }

    #[constructor]
    fn constructor(ref self: ContractState, teacher_address: ContractAddress) {
        self.teacher_address.write(teacher_address)
    }

    #[abi(embed_v0)]
    impl Classroom of IClassroom<ContractState> {
        fn add_student(ref self: ContractState, student_id: felt252, name: felt252, grade: u8) {
            let teacher_address = self.teacher.address.read();
            assert(get_caller_address() == teacher_address, 'Cannot add student')

            let student = Student { name: name, grade, grade };
            self.student.write(student_id, student);

            self.emit(StudentAdded { name, student_id, grade })
        }

        fn update_student(ref self: ContractState, amount: felt252) {
            let mut student = self.student.read(student_id);
            student.grade = upgrade;
            self.student.write(student_id, student);
        }

        fn get_student(self: @ContractState, student_id: felt252) -> felt252 {
            self.students.read(student_id)
        }
    }
}
