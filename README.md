# 🌱 GramCare — Blockchain Powered Healthcare System

## 🔗 BLOCKCHAIN — CORE HIGHLIGHT
**At the heart of GramCare is a blockchain-based prescription verification system** that prevents fake prescriptions and builds trust between Doctors, Patients, and Pharmacies.

**How it works (high level):**
1. **Doctor issues a prescription** via the backend. The prescription details are sent to a Solidity smart contract (e.g., `PrescriptionRegistry.sol`).
2. The smart contract stores an immutable record and a **Transaction Hash (Tx Hash)** is produced.
3. The backend stores that **Tx Hash** alongside minimal prescription metadata in the database (MongoDB).
4. A **QR code** (containing the prescription ID or Tx Hash) is generated for the patient.
5. **Pharmacy scans the QR code**, backend retrieves the on-chain record using the Tx Hash, and verifies authenticity:
   - If on-chain data and metadata match → **authentic** ✅
   - If mismatch → **flagged as fake** ❌

---

## Overview
GramCare connects Patients, Doctors, and Pharmacies in a secure ecosystem. Prescriptions are anchored on blockchain to guarantee immutability. Patients use a Flutter mobile app; Pharmacies use a React dashboard. Doctors issue prescriptions and conduct audio/video consultations. Pharmacy stock updates are reflected back to patients in real time.

> **Access for those without internet or literacy:**  
> Those who are illiterate or without internet can visit their nearest Panchayat office to get connected with doctors and services, with the help of health workers.

---

## Key Features

### Patient (Flutter)
- Secure registration & profile.
- Book appointments.
- Audio/video consultations with doctors.
- Receive blockchain-backed prescriptions via QR code.
- View pharmacy stock updates (reflected from pharmacy dashboard).
- Scan and verify prescriptions.

### Doctor
- Issue blockchain-backed prescriptions (Tx Hash generation).
- Manage appointments and patient records.
- Start audio/video consultations.

### Pharmacy (React)
- Scan QR codes from patient prescriptions.
- Verify prescription authenticity against blockchain.
- Update medicine stock (updates seen by patients).
- Manage prescription history and fulfillments.

---

## Tech Stack (concise)
- **Mobile app:** Flutter  
- **Pharmacy dashboard:** React.js  
- **Backend API:** Node.js (Express)  
- **Blockchain:** Solidity, Hardhat (deploy to Ethereum/Polygon or testnet)  
- **Database:** MongoDB  
- **Realtime / Video:** WebRTC or Agora SDK  
- **QR scanning:** `mobile_scanner` (Flutter)

---

## System Workflow (simple)

```
Doctor -> Issues Prescription -> Smart Contract (on-chain)
-> Tx Hash -> MongoDB (metadata)
-> QR code delivered to Patient (Flutter)

Patient -> Shows QR code to Pharmacy

Pharmacy -> Scans QR -> Backend verifies on-chain using Tx Hash
-> If valid: dispense medicine
-> If invalid: flag & report
```

---

## Quick Setup (local dev)

### Backend (Node + Smart Contracts)
```bash
cd backend
npm install
# Run a local node for testing
npx hardhat node
# Compile contracts
npx hardhat compile
# Deploy contracts to local node (example)
npx hardhat run scripts/deploy.js --network localhost
# Start backend
npm run dev
```

Make sure MongoDB is running locally or configure a MongoDB Atlas connection string in your environment variables.

### Patient App (Flutter)
```bash
cd patient-app
flutter pub get
# Set API_BASE_URL in app config to your backend (or ngrok https URL)
flutter run
```

### Pharmacy Dashboard (React)
```bash
cd pharmacy-dashboard
npm install
# Set REACT_APP_API_URL in .env to your backend 
npm start
```

## Security & Privacy

- Role-based authentication (JWT) for Patients, Doctors, and Pharmacies.
- Only minimal metadata stored off-chain; full prescription integrity is anchored on-chain.
- Encrypt sensitive data at rest and in transit (TLS/HTTPS).
- Follow local regulations and privacy best practices for medical data.

Community Impact
GramCare aims to make healthcare more transparent and accessible. By combining blockchain immutability
with mobile and web apps, the system protects patients against prescription fraud and connects underserved 
populations to care — including support through Panchayat offices and health workers for those without internet access.

Thank You..❤️
