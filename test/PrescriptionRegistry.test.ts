import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { PrescriptionRegistry } from "../typechain-types";

describe("PrescriptionRegistry", function () {
    let prescriptionRegistry: PrescriptionRegistry;
    let admin: Signer;
    let doctor: Signer;
    let pharmacy: Signer;
    let unauthorizedUser: Signer;

    let adminAddress: string;
    let doctorAddress: string;
    let pharmacyAddress: string;
    let unauthorizedAddress: string;

    beforeEach(async function () {
        // Get signers
        [admin, doctor, pharmacy, unauthorizedUser] = await ethers.getSigners();

        // Get addresses
        adminAddress = await admin.getAddress();
        doctorAddress = await doctor.getAddress();
        pharmacyAddress = await pharmacy.getAddress();
        unauthorizedAddress = await unauthorizedUser.getAddress();

        // Deploy contract
        const PrescriptionRegistryFactory = await ethers.getContractFactory("PrescriptionRegistry");
        prescriptionRegistry = await PrescriptionRegistryFactory.deploy();
        await prescriptionRegistry.waitForDeployment();

        // Authorize doctor and pharmacy
        await prescriptionRegistry.connect(admin).authorizeDoctor(doctorAddress);
        await prescriptionRegistry.connect(admin).authorizePharmacy(pharmacyAddress);
    });

    describe("Deployment", function () {
        it("Should set the correct admin", async function () {
            expect(await prescriptionRegistry.admin()).to.equal(adminAddress);
        });

        it("Should initialize prescription count to 0", async function () {
            expect(await prescriptionRegistry.prescriptionCount()).to.equal(0);
        });
    });

    describe("Authorization", function () {
        it("Should allow admin to authorize doctors", async function () {
            const newDoctor = await ethers.Wallet.createRandom().getAddress();

            await expect(prescriptionRegistry.connect(admin).authorizeDoctor(newDoctor))
                .to.emit(prescriptionRegistry, "DoctorAuthorized")
                .withArgs(newDoctor);

            expect(await prescriptionRegistry.authorizedDoctors(newDoctor)).to.be.true;
        });

        it("Should allow admin to authorize pharmacies", async function () {
            const newPharmacy = await ethers.Wallet.createRandom().getAddress();

            await expect(prescriptionRegistry.connect(admin).authorizePharmacy(newPharmacy))
                .to.emit(prescriptionRegistry, "PharmacyAuthorized")
                .withArgs(newPharmacy);

            expect(await prescriptionRegistry.authorizedPharmacies(newPharmacy)).to.be.true;
        });

        it("Should not allow non-admin to authorize doctors", async function () {
            const newDoctor = await ethers.Wallet.createRandom().getAddress();

            await expect(
                prescriptionRegistry.connect(unauthorizedUser).authorizeDoctor(newDoctor)
            ).to.be.revertedWith("Only admin can call this function");
        });

        it("Should not allow non-admin to authorize pharmacies", async function () {
            const newPharmacy = await ethers.Wallet.createRandom().getAddress();

            await expect(
                prescriptionRegistry.connect(unauthorizedUser).authorizePharmacy(newPharmacy)
            ).to.be.revertedWith("Only admin can call this function");
        });
    });

    describe("Prescription Issuance", function () {
        const samplePrescription = {
            medicines: ["Paracetamol", "Ibuprofen"],
            dosages: ["500mg twice daily", "200mg once daily"],
            consultationDate: "2024-01-15",
            expiryDate: "2024-02-15"
        };

        it("Should allow authorized doctor to issue prescription", async function () {
            await expect(
                prescriptionRegistry.connect(doctor).issuePrescription(
                    samplePrescription.medicines,
                    samplePrescription.dosages,
                    samplePrescription.consultationDate,
                    samplePrescription.expiryDate
                )
            ).to.emit(prescriptionRegistry, "PrescriptionIssued")
                .withArgs(1, doctorAddress);

            expect(await prescriptionRegistry.prescriptionCount()).to.equal(1);
        });

        it("Should return correct prescription ID", async function () {
            const tx = await prescriptionRegistry.connect(doctor).issuePrescription(
                samplePrescription.medicines,
                samplePrescription.dosages,
                samplePrescription.consultationDate,
                samplePrescription.expiryDate
            );

            const receipt = await tx.wait();
            const event = receipt?.logs.find(log => {
                try {
                    return prescriptionRegistry.interface.parseLog(log as any)?.name === "PrescriptionIssued";
                } catch {
                    return false;
                }
            });

            if (event) {
                const parsed = prescriptionRegistry.interface.parseLog(event as any);
                expect(parsed?.args[0]).to.equal(1);
            }
        });

        it("Should store prescription data correctly", async function () {
            await prescriptionRegistry.connect(doctor).issuePrescription(
                samplePrescription.medicines,
                samplePrescription.dosages,
                samplePrescription.consultationDate,
                samplePrescription.expiryDate
            );

            // Use verifyPrescription to get full prescription data including arrays
            const result = await prescriptionRegistry.verifyPrescription(1);
            const prescription = result[2]; // The full prescription struct

            expect(prescription.id).to.equal(1);
            expect(prescription.doctor).to.equal(doctorAddress);
            expect(prescription.consultationDate).to.equal(samplePrescription.consultationDate);
            expect(prescription.expiryDate).to.equal(samplePrescription.expiryDate);
            expect(prescription.valid).to.be.true;
            expect(prescription.dispensed).to.be.false;
            expect(prescription.dispensedBy).to.equal(ethers.ZeroAddress);
            expect(prescription.dispensedAt).to.equal(0);

            // Note: medicines and dosages arrays may not be directly accessible
            // from the prescriptions mapping due to Solidity limitations
            // They are included in the verifyPrescription return value
        });

        it("Should not allow unauthorized user to issue prescription", async function () {
            await expect(
                prescriptionRegistry.connect(unauthorizedUser).issuePrescription(
                    samplePrescription.medicines,
                    samplePrescription.dosages,
                    samplePrescription.consultationDate,
                    samplePrescription.expiryDate
                )
            ).to.be.revertedWith("Not an authorized doctor");
        });

        it("Should handle empty prescription data", async function () {
            await expect(
                prescriptionRegistry.connect(doctor).issuePrescription(
                    [],
                    [],
                    "",
                    ""
                )
            ).to.emit(prescriptionRegistry, "PrescriptionIssued");
        });
    });

    describe("Prescription Verification", function () {
        const samplePrescription = {
            medicines: ["Paracetamol", "Ibuprofen"],
            dosages: ["500mg twice daily", "200mg once daily"],
            consultationDate: "2024-01-15",
            expiryDate: "2024-02-15"
        };

        beforeEach(async function () {
            await prescriptionRegistry.connect(doctor).issuePrescription(
                samplePrescription.medicines,
                samplePrescription.dosages,
                samplePrescription.consultationDate,
                samplePrescription.expiryDate
            );
        });

        it("Should verify valid prescription", async function () {
            const result = await prescriptionRegistry.verifyPrescription(1);

            expect(result[0]).to.be.true; // isValid
            expect(result[1]).to.be.false; // isDispensed
            expect(result[2].id).to.equal(1); // prescription data
            expect(result[2].doctor).to.equal(doctorAddress);
            expect(result[2].valid).to.be.true;
            expect(result[2].dispensed).to.be.false;
        });

        it("Should return false for non-existent prescription", async function () {
            const result = await prescriptionRegistry.verifyPrescription(999);

            expect(result[0]).to.be.false; // isValid
            expect(result[1]).to.be.false; // isDispensed
            expect(result[2].id).to.equal(0); // empty prescription
        });

        it("Should return false for prescription ID 0", async function () {
            const result = await prescriptionRegistry.verifyPrescription(0);

            expect(result[0]).to.be.false;
            expect(result[1]).to.be.false;
            expect(result[2].id).to.equal(0);
        });

        it("Should be callable by anyone", async function () {
            // Verify that verification can be called by any address
            const result1 = await prescriptionRegistry.connect(doctor).verifyPrescription(1);
            const result2 = await prescriptionRegistry.connect(pharmacy).verifyPrescription(1);
            const result3 = await prescriptionRegistry.connect(unauthorizedUser).verifyPrescription(1);

            expect(result1[0]).to.equal(result2[0]).to.equal(result3[0]);
        });
    });

    describe("Prescription Dispensing", function () {
        const samplePrescription = {
            medicines: ["Paracetamol", "Ibuprofen"],
            dosages: ["500mg twice daily", "200mg once daily"],
            consultationDate: "2024-01-15",
            expiryDate: "2024-02-15"
        };

        beforeEach(async function () {
            await prescriptionRegistry.connect(doctor).issuePrescription(
                samplePrescription.medicines,
                samplePrescription.dosages,
                samplePrescription.consultationDate,
                samplePrescription.expiryDate
            );
        });

        it("Should allow authorized pharmacy to dispense prescription", async function () {
            await expect(
                prescriptionRegistry.connect(pharmacy).dispensePrescription(1)
            ).to.emit(prescriptionRegistry, "PrescriptionDispensed")
                .withArgs(1, pharmacyAddress);
        });

        it("Should update prescription status after dispensing", async function () {
            // Check initial state via verifyPrescription
            const beforeResult = await prescriptionRegistry.verifyPrescription(1);
            const beforePrescription = beforeResult[2];
            expect(beforePrescription.dispensed).to.be.false;
            expect(beforePrescription.dispensedBy).to.equal(ethers.ZeroAddress);
            expect(beforePrescription.dispensedAt).to.equal(0);

            await prescriptionRegistry.connect(pharmacy).dispensePrescription(1);

            // Check updated state via verifyPrescription
            const afterResult = await prescriptionRegistry.verifyPrescription(1);
            const afterPrescription = afterResult[2];
            expect(afterPrescription.dispensed).to.be.true;
            expect(afterPrescription.dispensedBy).to.equal(pharmacyAddress);
            expect(afterPrescription.dispensedAt).to.be.greaterThan(0);
        });

        it("Should update verification results after dispensing", async function () {
            const beforeResult = await prescriptionRegistry.verifyPrescription(1);
            expect(beforeResult[1]).to.be.false; // isDispensed

            await prescriptionRegistry.connect(pharmacy).dispensePrescription(1);

            const afterResult = await prescriptionRegistry.verifyPrescription(1);
            expect(afterResult[0]).to.be.true; // still valid
            expect(afterResult[1]).to.be.true; // now dispensed
        });

        it("Should not allow unauthorized user to dispense prescription", async function () {
            await expect(
                prescriptionRegistry.connect(unauthorizedUser).dispensePrescription(1)
            ).to.be.revertedWith("Not an authorized pharmacy");
        });

        it("Should not allow dispensing invalid prescription", async function () {
            await expect(
                prescriptionRegistry.connect(pharmacy).dispensePrescription(999)
            ).to.be.revertedWith("Invalid prescription");
        });

        it("Should not allow dispensing already dispensed prescription", async function () {
            await prescriptionRegistry.connect(pharmacy).dispensePrescription(1);

            await expect(
                prescriptionRegistry.connect(pharmacy).dispensePrescription(1)
            ).to.be.revertedWith("Already dispensed");
        });

        it("Should not allow doctor to dispense prescription", async function () {
            await expect(
                prescriptionRegistry.connect(doctor).dispensePrescription(1)
            ).to.be.revertedWith("Not an authorized pharmacy");
        });
    });

    describe("Multiple Prescriptions", function () {
        it("Should handle multiple prescriptions correctly", async function () {
            const prescription1 = {
                medicines: ["Medicine A"],
                dosages: ["Dosage A"],
                consultationDate: "2024-01-15",
                expiryDate: "2024-02-15"
            };

            const prescription2 = {
                medicines: ["Medicine B"],
                dosages: ["Dosage B"],
                consultationDate: "2024-01-16",
                expiryDate: "2024-02-16"
            };

            await prescriptionRegistry.connect(doctor).issuePrescription(
                prescription1.medicines,
                prescription1.dosages,
                prescription1.consultationDate,
                prescription1.expiryDate
            );

            await prescriptionRegistry.connect(doctor).issuePrescription(
                prescription2.medicines,
                prescription2.dosages,
                prescription2.consultationDate,
                prescription2.expiryDate
            );

            expect(await prescriptionRegistry.prescriptionCount()).to.equal(2);

            const result1 = await prescriptionRegistry.verifyPrescription(1);
            const result2 = await prescriptionRegistry.verifyPrescription(2);

            // Access prescription data through the verification results
            expect(result1[2].id).to.equal(1);
            expect(result2[2].id).to.equal(2);
            expect(result1[2].doctor).to.equal(doctorAddress);
            expect(result2[2].doctor).to.equal(doctorAddress);
        });

        it("Should allow dispensing prescriptions independently", async function () {
            // Issue two prescriptions
            await prescriptionRegistry.connect(doctor).issuePrescription(
                ["Medicine A"],
                ["Dosage A"],
                "2024-01-15",
                "2024-02-15"
            );

            await prescriptionRegistry.connect(doctor).issuePrescription(
                ["Medicine B"],
                ["Dosage B"],
                "2024-01-16",
                "2024-02-16"
            );

            // Dispense only the first one
            await prescriptionRegistry.connect(pharmacy).dispensePrescription(1);

            const result1 = await prescriptionRegistry.verifyPrescription(1);
            const result2 = await prescriptionRegistry.verifyPrescription(2);

            expect(result1[1]).to.be.true; // first is dispensed
            expect(result2[1]).to.be.false; // second is not dispensed
        });
    });

    describe("Edge Cases", function () {
        it("Should handle very long medicine names and dosages", async function () {
            const longMedicine = "A".repeat(1000);
            const longDosage = "B".repeat(1000);

            await expect(
                prescriptionRegistry.connect(doctor).issuePrescription(
                    [longMedicine],
                    [longDosage],
                    "2024-01-15",
                    "2024-02-15"
                )
            ).to.emit(prescriptionRegistry, "PrescriptionIssued");
        });

        it("Should handle many medicines in one prescription", async function () {
            const manyMedicines = Array.from({ length: 100 }, (_, i) => `Medicine${i}`);
            const manyDosages = Array.from({ length: 100 }, (_, i) => `Dosage${i}`);

            await expect(
                prescriptionRegistry.connect(doctor).issuePrescription(
                    manyMedicines,
                    manyDosages,
                    "2024-01-15",
                    "2024-02-15"
                )
            ).to.emit(prescriptionRegistry, "PrescriptionIssued");
        });

        it("Should handle unicode characters in prescription data", async function () {
            const unicodeMedicine = "Paracétamol-™";
            const unicodeDosage = "500mg 每日三次";
            const unicodeDate = "२०२४-०१-१५";

            await expect(
                prescriptionRegistry.connect(doctor).issuePrescription(
                    [unicodeMedicine],
                    [unicodeDosage],
                    unicodeDate,
                    "2024-02-15"
                )
            ).to.emit(prescriptionRegistry, "PrescriptionIssued");
        });
    });
});