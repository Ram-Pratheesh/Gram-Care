// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract PrescriptionRegistry {
    struct Prescription {
        uint256 id;
        address doctor;
        string[] medicines;
        string[] dosages;
        string consultationDate;
        string expiryDate;
        bool valid;
        bool dispensed;
        address dispensedBy;
        uint256 dispensedAt;
    }

    uint256 public prescriptionCount;
    mapping(uint256 => Prescription) public prescriptions;
    mapping(address => bool) public authorizedDoctors;
    mapping(address => bool) public authorizedPharmacies;
    address public admin;

    event PrescriptionIssued(uint256 id, address doctor);
    event PrescriptionDispensed(uint256 id, address pharmacy);
    event DoctorAuthorized(address doctor);
    event PharmacyAuthorized(address pharmacy);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyAuthorizedDoctor() {
        require(authorizedDoctors[msg.sender], "Not an authorized doctor");
        _;
    }

    modifier onlyAuthorizedPharmacy() {
        require(authorizedPharmacies[msg.sender], "Not an authorized pharmacy");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function authorizeDoctor(address _doctor) public onlyAdmin {
        authorizedDoctors[_doctor] = true;
        emit DoctorAuthorized(_doctor);
    }

    function authorizePharmacy(address _pharmacy) public onlyAdmin {
        authorizedPharmacies[_pharmacy] = true;
        emit PharmacyAuthorized(_pharmacy);
    }

    function issuePrescription(
        string[] memory _medicines,
        string[] memory _dosages,
        string memory _consultationDate,
        string memory _expiryDate
    ) public onlyAuthorizedDoctor returns (uint256) {
        require(_medicines.length == _dosages.length, "Medicines and dosages length mismatch");
        
        prescriptionCount++;

        prescriptions[prescriptionCount] = Prescription({
            id: prescriptionCount,
            doctor: msg.sender,
            medicines: _medicines,
            dosages: _dosages,
            consultationDate: _consultationDate,
            expiryDate: _expiryDate,
            valid: true,
            dispensed: false,
            dispensedBy: address(0),
            dispensedAt: 0
        });

        emit PrescriptionIssued(prescriptionCount, msg.sender);
        return prescriptionCount;
    }

    function dispensePrescription(uint256 _id) public onlyAuthorizedPharmacy {
        require(_id > 0 && _id <= prescriptionCount, "Invalid prescription ID");
        require(prescriptions[_id].valid, "Invalid prescription");
        require(!prescriptions[_id].dispensed, "Already dispensed");

        prescriptions[_id].dispensed = true;
        prescriptions[_id].dispensedBy = msg.sender;
        prescriptions[_id].dispensedAt = block.timestamp;

        emit PrescriptionDispensed(_id, msg.sender);
    }

    function verifyPrescription(uint256 _id) public view returns (bool, bool, Prescription memory) {
        if (_id == 0 || _id > prescriptionCount) {
            Prescription memory empty;
            return (false, false, empty);
        }

        Prescription memory prescription = prescriptions[_id];
        return (prescription.valid, prescription.dispensed, prescription);
    }

    // Helper function to get medicines array for a prescription
    function getPrescriptionMedicines(uint256 _id) public view returns (string[] memory) {
        require(_id > 0 && _id <= prescriptionCount, "Invalid prescription ID");
        return prescriptions[_id].medicines;
    }

    // Helper function to get dosages array for a prescription
    function getPrescriptionDosages(uint256 _id) public view returns (string[] memory) {
        require(_id > 0 && _id <= prescriptionCount, "Invalid prescription ID");
        return prescriptions[_id].dosages;
    }

    // Function to get basic prescription info (without arrays)
    function getPrescriptionBasicInfo(uint256 _id) public view returns (
        uint256 id,
        address doctor,
        string memory consultationDate,
        string memory expiryDate,
        bool valid,
        bool dispensed,
        address dispensedBy,
        uint256 dispensedAt
    ) {
        require(_id > 0 && _id <= prescriptionCount, "Invalid prescription ID");
        Prescription storage prescription = prescriptions[_id];
        return (
            prescription.id,
            prescription.doctor,
            prescription.consultationDate,
            prescription.expiryDate,
            prescription.valid,
            prescription.dispensed,
            prescription.dispensedBy,
            prescription.dispensedAt
        );
    }

    // Function to get full prescription details in separate calls
    function getPrescriptionDetails(uint256 _id) public view returns (
        uint256 id,
        address doctor,
        string[] memory medicines,
        string[] memory dosages,
        string memory consultationDate,
        string memory expiryDate,
        bool valid,
        bool dispensed,
        address dispensedBy,
        uint256 dispensedAt
    ) {
        require(_id > 0 && _id <= prescriptionCount, "Invalid prescription ID");
        Prescription storage prescription = prescriptions[_id];
        return (
            prescription.id,
            prescription.doctor,
            prescription.medicines,
            prescription.dosages,
            prescription.consultationDate,
            prescription.expiryDate,
            prescription.valid,
            prescription.dispensed,
            prescription.dispensedBy,
            prescription.dispensedAt
        );
    }
}