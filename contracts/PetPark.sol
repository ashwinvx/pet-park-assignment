//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title A contract for Pet Park implementation
/// @author Ashwin Rachakonda 💯💯😎💯💯
/// @notice Used to managing animals in the pet park and also lets users to borrow them
contract PetPark{
    address private _owner;
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male, 
        Female
    }

    struct Borrower {
        uint8 age;
        uint8 gender;
    }
    
    event Added(uint animalType, uint animalCount);
    event Borrowed(uint animalType);
    event Returned(uint animalType);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not an owner");
        _;
    }

    modifier validAge(uint age) {
        require(age > 0, "Invalid Age");
        _;
    }

    modifier validAnimal(uint animalType) {
        require(animalType == uint(AnimalType.Fish) || animalType == uint(AnimalType.Cat) || animalType == uint(AnimalType.Dog) || animalType == uint(AnimalType.Rabbit) || animalType == uint(AnimalType.Parrot), "Invalid animal type");
        _;
    }

    modifier validHuman(uint gender) {
        require(gender == uint(Gender.Male) || gender == uint(Gender.Female), "Invalid human type");
        _;
    }

    mapping(uint => uint) public animalCounts;//Map of animal and the their respective count
    mapping(address => uint) private borrowerAnimalMap;//Map of user and the type of animal borrowed
    mapping(address => Borrower) private borrowerToAgeGenderMap;//Map of user to age, gender map to make sure user is not borrowing with different values
     
    /// @notice Adds animals to the park
    /// @param _animalType type of animal.
    /// @param _animalCount number of animals.
    function add(uint _animalType, uint _animalCount) external onlyOwner validAnimal(_animalType) {
        //update map
        animalCounts[_animalType]+=_animalCount;
        emit Added(_animalType, _animalCount);
    }

    /// @notice Lets users borrow animals
    /// @param _age age of user borrowing.
    /// @param _gender gender of user borrowing.
    /// @param _animalType type of animal user wants to borrow.
    function borrow(uint8 _age, uint8 _gender, uint _animalType) external validAge(_age) validAnimal(_animalType) validHuman(_gender) {
        //check if address has called this function before using other values for Gender and Age
        if(borrowerToAgeGenderMap[msg.sender].age != 0 || borrowerToAgeGenderMap[msg.sender].gender != 0) {
            require(borrowerToAgeGenderMap[msg.sender].age == _age, "Invalid Age");
            require(borrowerToAgeGenderMap[msg.sender].gender == _gender, "Invalid Gender");
        }
        //Can borrow only one animal at a time
        require(borrowerAnimalMap[msg.sender] == 0, "Already adopted a pet");
        //Men can only borrow Dog and Fish
        if(_gender == uint(Gender.Male)){
            require(_animalType == uint(AnimalType.Fish) || _animalType == uint(AnimalType.Dog), "Invalid animal for men");
        } 
        //Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat
        else{
            require(_animalType != uint(AnimalType.Cat) && _age < 40, "Invalid animal for women under 40");
        }
        //animal is not available to borrow
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        //update maps
        animalCounts[_animalType]--;
        borrowerAnimalMap[msg.sender] = _animalType;
        borrowerToAgeGenderMap[msg.sender] = Borrower(_age, _gender);
        emit Borrowed(_animalType);
    }

    /// @notice Lets users give animals back
    function giveBackAnimal() external {
        //user hasn't borrowed before
        require(borrowerAnimalMap[msg.sender] > 0, "No borrowed pets");

        //update maps
        uint animalType = borrowerAnimalMap[msg.sender];
        animalCounts[animalType]++;
        borrowerAnimalMap[msg.sender] = uint(AnimalType.None);
        emit Returned(animalType);
    }
}