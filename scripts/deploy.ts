import { ethers } from "hardhat";

async function main() {
    console.log("🚀 Deploying PrescriptionRegistry...");

    // 1️⃣ Deploy the contract
    const PrescriptionRegistry = await ethers.getContractFactory("PrescriptionRegistry");
    const prescriptionRegistry = await PrescriptionRegistry.deploy();
    await prescriptionRegistry.waitForDeployment();

    const contractAddress = await prescriptionRegistry.getAddress();
    console.log("✅ PrescriptionRegistry deployed to:", contractAddress);

    // 2️⃣ Get default accounts
    const [admin, doctor, pharmacy] = await ethers.getSigners();

    console.log("🧑‍💼 Admin account:", admin.address);
    console.log("👨‍⚕️ Doctor account:", doctor.address);
    console.log("🏥 Pharmacy account:", pharmacy.address);

    // 3️⃣ Authorize doctor and pharmacy
    const txDoctor = await prescriptionRegistry.authorizeDoctor(doctor.address);
    await txDoctor.wait();

    const txPharmacy = await prescriptionRegistry.authorizePharmacy(pharmacy.address);
    await txPharmacy.wait();

    console.log(`✅ Doctor authorized: ${doctor.address}`);
    console.log(`✅ Pharmacy authorized: ${pharmacy.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
