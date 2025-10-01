import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import mongoose, { Schema, Document, Collection } from "mongoose";
import { ethers, Contract } from "ethers";
import multer from "multer";
import path from "path";
import fs from "fs/promises";
import QRCode from "qrcode";
import PDFDocument from "pdfkit";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { Request, Response, NextFunction } from "express";
import Patient from "./models/patient";
import contractJson from "../../../artifacts/contracts/PrescriptionRegistry.sol/PrescriptionRegistry.json";
import PatientAccount from "./models/patient_account";
import Pharmacy from "./models/pharmacy";


import { calculateDistance } from "./geoUtils";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Serve static files for uploads and generated PDFs
app.use("/uploads", express.static("uploads"));
app.use("/pdfs", express.static("pdfs"));

// ==================== DOCTOR MODEL & AUTH SYSTEM ====================

interface IDoctor extends Document {
    _id: mongoose.Types.ObjectId;
    fullName: string;
    dateOfBirth: Date;
    gender: "Male" | "Female" | "Other";
    medicalRegNo: string;
    qualifications: string;
    specialization: string;
    experience: number;
    mobileNumber: string;
    email: string;
    password: string;
    walletAddress: string;
    isActive: boolean;
    isMobileVerified: boolean;
    createdAt: Date;
    comparePassword(password: string): Promise<boolean>;
}

const DoctorSchema: Schema = new Schema(
    {
        fullName: { type: String, required: true },
        dateOfBirth: { type: Date, required: true },
        gender: {
            type: String,
            required: true,
            enum: ["Male", "Female", "Other"]
        },
        medicalRegNo: {
            type: String,
            required: true,
            unique: true
        },
        qualifications: { type: String, required: true },
        specialization: { type: String, required: true },
        experience: { type: Number, required: true },
        mobileNumber: {
            type: String,
            required: true,
            unique: true
        },
        email: {
            type: String,
            required: true,
            unique: true
        },
        password: { type: String, required: true },
        walletAddress: { type: String, required: true },
        isActive: { type: Boolean, default: true },
        isMobileVerified: { type: Boolean, default: false }
    },
    { timestamps: true }
);
const pharmacies = [
    { id: "P001", name: "Nabha Central Pharmacy", latitude: 30.3745, longitude: 76.1508 },
    { id: "P002", name: "Village Care Pharmacy", latitude: 30.3548, longitude: 76.1320 },
    { id: "P003", name: "Health Hub Pharmacy", latitude: 30.3890, longitude: 76.1700 },
];
const prescriptions: any[] = [];
// Hash password before saving
DoctorSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();
    const saltRounds = 12;
    this.password = await bcrypt.hash(this.password as string, saltRounds);
    next();
});

// Compare password method
DoctorSchema.methods.comparePassword = async function (password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
};

const Doctor = mongoose.model<IDoctor>("Doctor", DoctorSchema);

// JWT Token Generation
const generateToken = (
    userId: string,
    role: string,
    userType: "doctor" | "pharmacy" | "patient" | "admin" = "doctor"
): string => {

    return jwt.sign(
        { userId, role, userType },
        process.env.JWT_SECRET || "your-secret-key-change-in-production",
        { expiresIn: process.env.JWT_EXPIRES_IN || "24h" } as jwt.SignOptions
    );
};

// Authentication Middleware
const authenticateToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.split(" ")[1];

        if (!token) {
            return res.status(401).json({ error: "Access token required" });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET || "your-secret-key-change-in-production") as any;

        // Check if it's a doctor token
        if (decoded.userType === "doctor") {
            const doctor = await Doctor.findById(decoded.userId);
            if (!doctor || !doctor.isActive) {
                return res.status(401).json({ error: "Invalid or inactive doctor" });
            }

            (req as any).user = {
                id: doctor._id.toString(), // FIX: Convert to string
                fullName: doctor.fullName,
                email: doctor.email,
                role: "doctor",
                userType: "doctor",
                walletAddress: doctor.walletAddress,
                medicalRegNo: doctor.medicalRegNo,
                specialization: doctor.specialization
            };
        } else {
            // Handle pharmacy/admin users (when you implement them later)
            return res.status(401).json({ error: "Invalid user type" });
        }

        next();
    } catch (error) {
        console.error("Auth error:", error);
        return res.status(403).json({ error: "Invalid or expired token" });
    }
};
// Role-based Authorization Middleware
const authorizeRole = (roles: string[]) => {
    return (req: Request, res: Response, next: NextFunction) => {
        const user = (req as any).user;

        if (!user) {
            return res.status(401).json({ error: "Authentication required" });
        }

        if (!roles.includes(user.role)) {
            return res.status(403).json({
                error: `Access denied. Required roles: ${roles.join(", ")}. Your role: ${user.role}`
            });
        }

        next();
    };
};

// ==================== SETUP & CONFIGURATION ====================

// Create directories if they don't exist
const createDirectories = async () => {
    const dirs = ["uploads", "pdfs"];
    for (const dir of dirs) {
        try {
            await fs.access(dir);
        } catch {
            await fs.mkdir(dir, { recursive: true });
        }
    }
};

// Multer configuration for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "uploads/");
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1E9);
        cb(null, "prescription-" + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 10 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|pdf/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);

        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb(new Error("Only image files (jpg, jpeg, png) and PDFs are allowed"));
        }
    }
});

// Environment variables
const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:8545";
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS || "";
const MONGO_URI = process.env.MONGO_URI || "";
const BASE_URL = process.env.BASE_URL || "http://localhost:4000";

if (!CONTRACT_ADDRESS || !MONGO_URI) {
    console.error("❌ Missing .env variables");
    process.exit(1);
}

// Blockchain setup
const provider = new ethers.JsonRpcProvider(RPC_URL);
const doctorWallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
const pharmacyWallet = new ethers.Wallet(process.env.PHARMACY_PRIVATE_KEY!, provider);
const adminWallet = new ethers.Wallet(process.env.ADMIN_PRIVATE_KEY!, provider);

const doctorContract = new ethers.Contract(CONTRACT_ADDRESS, contractJson.abi, doctorWallet);
const pharmacyContract = new ethers.Contract(CONTRACT_ADDRESS, contractJson.abi, pharmacyWallet);
const adminContract = new ethers.Contract(CONTRACT_ADDRESS, contractJson.abi, adminWallet);

// MongoDB connection
mongoose
    .connect(MONGO_URI)
    .then(() => console.log("✅ MongoDB connected"))
    .catch((err) => {
        console.error("❌ MongoDB connection error:", err);
        process.exit(1);
    });

// ==================== HELPER FUNCTIONS ====================

function bigintToString(obj: any): any {
    if (typeof obj === "bigint") return obj.toString();
    if (Array.isArray(obj)) return obj.map(bigintToString);
    if (typeof obj === "object" && obj !== null) {
        const res: any = {};
        for (const key in obj) res[key] = bigintToString(obj[key]);
        return res;
    }
    return obj;
}

const generateQRCode = async (data: string): Promise<string> => {
    try {
        return await QRCode.toDataURL(data);
    } catch (error) {
        throw new Error("Failed to generate QR code");
    }
};

const generatePrescriptionPDF = async (
    patient: any,
    prescriptionData: any,
    qrCodeData: string
): Promise<string> => {
    const doc = new PDFDocument();
    const filename = `prescription-${patient.prescriptionId}.pdf`;
    const filepath = path.join("pdfs", filename);

    doc.pipe(require('fs').createWriteStream(filepath));

    // Header
    doc.fontSize(20).text("DIGITAL PRESCRIPTION", { align: "center" });
    doc.moveDown();

    // Patient Information
    doc.fontSize(16).text("Patient Information", { underline: true });
    doc.fontSize(12)
        .text(`Name: ${patient.name}`)
        .text(`Patient ID: ${patient.patientId}`)
        .text(`Age: ${patient.age}`)
        .text(`Gender: ${patient.gender}`)
        .text(`Address: ${patient.address}`)
        .moveDown();

    // Prescription Details
    doc.fontSize(16).text("Prescription Details", { underline: true });
    doc.fontSize(12)
        .text(`Prescription ID: ${patient.prescriptionId}`)
        .text(`Doctor: ${prescriptionData.doctorName || 'N/A'}`)
        .text(`Medical Reg No: ${prescriptionData.medicalRegNo || 'N/A'}`)
        .text(`Specialization: ${prescriptionData.specialization || 'N/A'}`)
        .text(`Consultation Date: ${prescriptionData.consultationDate}`)
        .text(`Expiry Date: ${prescriptionData.expiryDate}`)
        .moveDown();

    // Medicines and Dosages
    doc.fontSize(16).text("Medications", { underline: true });
    if (prescriptionData.medicines && prescriptionData.dosages) {
        for (let i = 0; i < prescriptionData.medicines.length; i++) {
            doc.fontSize(12)
                .text(`${i + 1}. ${prescriptionData.medicines[i]}`)
                .text(`   Dosage: ${prescriptionData.dosages[i]}`)
                .moveDown(0.5);
        }
    }

    // QR Code
    doc.moveDown();
    doc.fontSize(16).text("Verification QR Code", { underline: true });
    doc.fontSize(10).text("Scan this QR code to verify the prescription:");

    const qrBuffer = Buffer.from(qrCodeData.split(',')[1], 'base64');
    doc.image(qrBuffer, { width: 150 });

    // Footer
    doc.moveDown();
    doc.fontSize(10)
        .text("This is a digitally generated prescription.", { align: "center" })
        .text(`Generated on: ${new Date().toLocaleString()}`, { align: "center" });

    doc.end();

    return filename;
};

const getUserContract = (role: string) => {
    switch (role) {
        case "doctor": return doctorContract;
        case "pharmacy": return pharmacyContract;
        case "admin": return adminContract;
        default: return doctorContract;
    }
};



createDirectories();
//patient registering routes



// ==================== DOCTOR AUTHENTICATION ROUTES ====================

// Doctor Registration
app.post("/api/doctor/register", async (req: Request, res: Response) => {
    try {
        const {
            fullName,
            dateOfBirth,
            gender,
            medicalRegNo,
            qualifications,
            specialization,
            experience,
            mobileNumber,
            email,
            password,
            confirmPassword
        } = req.body;

        // Validation
        if (!fullName || !dateOfBirth || !gender || !medicalRegNo || !qualifications ||
            !specialization || !experience || !mobileNumber || !email || !password) {
            return res.status(400).json({ error: "All fields are required" });
        }

        if (password !== confirmPassword) {
            return res.status(400).json({ error: "Passwords do not match" });
        }

        if (!["Male", "Female", "Other"].includes(gender)) {
            return res.status(400).json({ error: "Invalid gender" });
        }

        // Check if doctor already exists
        const existingDoctor = await Doctor.findOne({
            $or: [{ email }, { medicalRegNo }, { mobileNumber }]
        });

        if (existingDoctor) {
            return res.status(409).json({
                error: "Doctor already exists with this email, medical registration number, or mobile number"
            });
        }

        // Create doctor
        const doctor = await Doctor.create({
            fullName,
            dateOfBirth: new Date(dateOfBirth),
            gender,
            medicalRegNo,
            qualifications,
            specialization,
            experience: Number(experience),
            mobileNumber,
            email,
            password,
            walletAddress: doctorWallet.address,
            isMobileVerified: true // Assuming OTP verification is handled on frontend
        });

        // Generate JWT token
        const token = generateToken(doctor._id.toString(), "doctor", "doctor");

        res.status(201).json({
            success: true,
            message: "Doctor registered successfully",
            doctor: {
                id: doctor._id,
                fullName: doctor.fullName,
                email: doctor.email,
                medicalRegNo: doctor.medicalRegNo,
                specialization: doctor.specialization,
                walletAddress: doctor.walletAddress
            },
            token
        });
    } catch (error: any) {
        console.error("Doctor registration error:", error);
        res.status(500).json({
            error: "Registration failed",
            details: error.message
        });
    }
});

// Doctor Login
app.post("/api/doctor/login", async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: "Email and password are required" });
        }

        // Find doctor by email or medical registration number
        const doctor = await Doctor.findOne({
            $or: [{ email }, { medicalRegNo: email }],
            isActive: true
        });

        if (!doctor) {
            return res.status(401).json({ error: "Invalid credentials" });
        }

        const isPasswordValid = await doctor.comparePassword(password);
        if (!isPasswordValid) {
            return res.status(401).json({ error: "Invalid credentials" });
        }

        // Generate JWT token
        const token = generateToken(doctor._id.toString(), "doctor", "doctor");

        res.json({
            success: true,
            message: "Login successful",
            doctor: {
                id: doctor._id,
                fullName: doctor.fullName,
                email: doctor.email,
                medicalRegNo: doctor.medicalRegNo,
                specialization: doctor.specialization,
                walletAddress: doctor.walletAddress
            },
            token
        });
    } catch (error: any) {
        console.error("Doctor login error:", error);
        res.status(500).json({
            error: "Login failed",
            details: error.message
        });
    }
});

app.post("/api/auth/login", async (req: Request, res: Response) => {
    try {
        const { role, identifier, password } = req.body;

        // Validate input
        if (!role || !identifier || !password) {
            return res.status(400).json({ error: "Role, identifier, and password are required" });
        }

        let user: any = null;
        const userType = role.toLowerCase();

        // Role-based login rules
        if (role === "doctor") {
            // Doctor logs in using EMAIL ONLY
            user = await Doctor.findOne({ email: identifier });
        } else if (role === "pharmacy") {
            // Pharmacy logs in using EMAIL ONLY
            user = await Pharmacy.findOne({ email: identifier });
        } else if (role === "patient") {
            // Patient logs in using USERNAME ONLY
            user = await PatientAccount.findOne({ username: identifier });
        } else {
            return res.status(400).json({ error: "Invalid role selected" });
        }

        // Validate user existence
        if (!user) {
            return res.status(401).json({ error: "Invalid credentials" });
        }

        // Validate password
        const isPasswordValid = await user.comparePassword(password);
        if (!isPasswordValid) {
            return res.status(401).json({ error: "Invalid credentials" });
        }

        // Generate JWT
        const token = generateToken(user._id.toString(), role, userType);

        // Send response
        res.json({
            success: true,
            message: "Login successful",
            token,
            user: {
                id: user._id,
                fullName: user.fullName,
                email: user.email || user.username, // Use username for patients who might not have email
                role,
            },
        });
    } catch (error: any) {
        console.error("Login error:", error);
        res.status(500).json({ error: "Login failed", details: error.message });
    }
});

// Get doctor profile
app.get("/api/doctor/profile", authenticateToken, authorizeRole(["doctor"]), async (req: Request, res: Response) => {
    try {
        const user = (req as any).user;

        const doctor = await Doctor.findById(user.id).select("-password");

        if (!doctor) {
            return res.status(404).json({ error: "Doctor not found" });
        }

        res.json({
            success: true,
            doctor: {
                id: doctor._id.toString(), // FIX: Convert to string
                fullName: doctor.fullName,
                dateOfBirth: doctor.dateOfBirth,
                gender: doctor.gender,
                medicalRegNo: doctor.medicalRegNo,
                qualifications: doctor.qualifications,
                specialization: doctor.specialization,
                experience: doctor.experience,
                mobileNumber: doctor.mobileNumber,
                email: doctor.email,
                walletAddress: doctor.walletAddress,
                isActive: doctor.isActive,
                isMobileVerified: doctor.isMobileVerified,
                createdAt: doctor.createdAt
            }
        });
    } catch (error: any) {
        res.status(500).json({
            error: "Failed to get profile",
            details: error.message
        });
    }
});

app.post('/api/patientsigin', async (req: Request, res: Response) => {
    try {
        const {
            fullName,
            dob,
            gender,
            address,
            primaryPhone,
            altPhone,
            email,
            govId,
            language,
            emergencyName,
            emergencyPhone,
            conditions,
            allergies,
            chronicMeds,
            vitals,
            bloodGroup,
            pharmacy,
            primaryDoctor,
            consentTreatment,
            consentResearch,
            insuranceProvider,
            policyNumber,
            device,
            lastSync,
            username, // Changed from 'login' to 'username'
            password,
            agreePolicy
        } = req.body;

        // Basic validation
        if (!fullName || !dob || !address || !primaryPhone || !govId || !emergencyName || !emergencyPhone || !username || !password) {
            return res.status(400).json({
                message: 'Required fields missing: fullName, dob, address, primaryPhone, govId, emergencyName, emergencyPhone, username, password' // Updated message
            });
        }

        if (!agreePolicy) {
            return res.status(400).json({ message: 'Policy agreement is required' });
        }

        // Check if username already exists
        const existing = await PatientAccount.findOne({ username }); // Changed from 'login' to 'username'
        if (existing) {
            return res.status(409).json({ message: 'Username already exists' });
        }

        // Generate patient ID
        const patientId = Math.floor(100000 + Math.random() * 900000).toString();

        // Create new patient account
        const patient = await PatientAccount.create({
            fullName,
            dob,
            gender,
            address,
            primaryPhone,
            altPhone,
            email,
            govId,
            language,
            emergencyName,
            emergencyPhone,
            conditions,
            allergies,
            chronicMeds,
            vitals,
            bloodGroup,
            pharmacy,
            primaryDoctor,
            consentTreatment,
            consentResearch,
            insuranceProvider,
            policyNumber,
            device,
            lastSync,
            username, // Changed from 'login' to 'username'
            password,
            agreePolicy,
            patientId
        });

        return res.status(201).json({
            message: 'Account created successfully',
            id: patient._id,
            patientId: patient.patientId,
            fullName: patient.fullName
        });

    } catch (error: any) {
        console.error('Patient signup error:', error);

        // Handle duplicate key errors
        if (error.code === 11000) {
            return res.status(409).json({ message: 'Username or Patient ID already exists' });
        }

        return res.status(500).json({
            message: 'Internal server error'
        });
    }
});


app.get("/api/doctor/patients", async (req: Request, res: Response) => {
    try {
        const { search, filter, page = 1, limit = 20 } = req.query;

        // Build query object
        const query: any = {};

        // Search functionality
        if (search && typeof search === 'string') {
            query.$or = [
                { fullName: { $regex: search, $options: 'i' } },
                { patientId: { $regex: search, $options: 'i' } },
                { username: { $regex: search, $options: 'i' } }
            ];
        }

        // Filter functionality
        let sortQuery: any = { createdAt: -1 }; // Default: Recent first

        if (filter === 'active') {
            // "Active" patients sorted by most recent update
            sortQuery = { updatedAt: -1 };
        }

        // Pagination
        const pageNum = parseInt(page as string) || 1;
        const limitNum = parseInt(limit as string) || 20;
        const skip = (pageNum - 1) * limitNum;

        // Fetch patients with pagination
        const patients = await PatientAccount.find(query)
            .select('fullName patientId username createdAt updatedAt') // Only select needed fields
            .sort(sortQuery)
            .skip(skip)
            .limit(limitNum)
            .lean(); // Use lean() for better performance

        // Get total count for pagination
        const total = await PatientAccount.countDocuments(query);

        // Transform data to match Flutter model
        const transformedPatients = patients.map(patient => ({
            id: patient.patientId,
            name: patient.fullName,
            // Removed age and gender as requested
        }));

        res.json({
            success: true,
            patients: transformedPatients,
            pagination: {
                currentPage: pageNum,
                totalPages: Math.ceil(total / limitNum),
                totalPatients: total,
                hasMore: pageNum * limitNum < total
            }
        });

    } catch (error: any) {
        console.error("Get patients error:", error);
        res.status(500).json({
            error: "Failed to fetch patients",
            details: error.message
        });
    }
});

// Get specific patient details (PROTECTED)
app.get("/api/doctor/patients/:patientId",
    authenticateToken,
    authorizeRole(["doctor"]),
    async (req: Request, res: Response) => {
        try {
            const { patientId } = req.params;

            const patient = await PatientAccount.findOne({ patientId })
                .select('-password') // Exclude password
                .lean();

            if (!patient) {
                return res.status(404).json({ error: "Patient not found" });
            }

            res.json({
                success: true,
                patient: {
                    id: patient.patientId,
                    name: patient.fullName,
                    username: patient.username,
                    primaryPhone: patient.primaryPhone,
                    email: patient.email,
                    address: patient.address,
                    emergencyContact: {
                        name: patient.emergencyName,
                        phone: patient.emergencyPhone
                    },
                    medicalInfo: {
                        conditions: patient.conditions,
                        allergies: patient.allergies,
                        chronicMeds: patient.chronicMeds,
                        bloodGroup: patient.bloodGroup
                    },
                    createdAt: patient.createdAt
                }
            });

        } catch (error: any) {
            console.error("Get patient details error:", error);
            res.status(500).json({
                error: "Failed to fetch patient details",
                details: error.message
            });
        }
    });
// ==================== PRESCRIPTION ROUTES ====================

// Doctor issues a prescription with optional file upload (PROTECTED)
app.post("/api/doctor/issue",
    authenticateToken,
    authorizeRole(["doctor"]),
    upload.single("prescriptionFile"),
    async (req, res) => {
        try {
            const user = (req as any).user;
            const {
                name,
                patientId,
                age,
                gender,
                address,
                medicines,
                dosages,
                consultationDate,
                expiryDate,
            } = req.body;

            if (!name || !patientId || !age || !gender || !address || !medicines || !dosages) {
                return res.status(400).json({ error: "Missing required fields" });
            }

            let medicineArray: string[];
            let dosageArray: string[];

            try {
                medicineArray = typeof medicines === 'string' ? JSON.parse(medicines) : medicines;
                dosageArray = typeof dosages === 'string' ? JSON.parse(dosages) : dosages;
            } catch (parseError) {
                return res.status(400).json({ error: "Invalid format for medicines or dosages" });
            }

            if (!Array.isArray(medicineArray) || !Array.isArray(dosageArray)) {
                return res.status(400).json({ error: "Medicines and dosages must be arrays" });
            }

            if (medicineArray.length !== dosageArray.length || medicineArray.length === 0) {
                return res.status(400).json({
                    error: "Medicines and dosages must be non-empty arrays of same length",
                });
            }

            // First, create the patient record without txHash
            const patient = await Patient.create({
                name,
                patientId,
                age: Number(age),
                gender,
                address,
                prescriptionId: "0", // Will be updated after blockchain transaction
                txHash: "pending", // Set as pending initially
                uploadedFile: req.file ? req.file.filename : null,
            });

            console.log("✅ Patient created in database with ID:", patient._id);

            // Now perform the blockchain transaction
            const tx = await doctorContract.issuePrescription(
                medicineArray,
                dosageArray,
                consultationDate || "",
                expiryDate || ""
            );

            console.log("🚀 Transaction sent, hash:", tx.hash);

            const receipt = await tx.wait();
            console.log("✅ Transaction mined. receipt:", {
                transactionHash: receipt.transactionHash ?? receipt.hash ?? null,
                status: receipt.status,
                blockNumber: receipt.blockNumber,
                logsLength: receipt.logs?.length ?? 0
            });

            if (!receipt) {
                throw new Error("Blockchain transaction failed");
            }

            // Get the actual transaction hash
            const actualTxHash = receipt.transactionHash || receipt.hash || tx.hash;

            let prescriptionId = "0";
            try {
                const eventLog = receipt.logs.find((log: any) => {
                    try {
                        const parsed = doctorContract.interface.parseLog(log);
                        return parsed?.name === "PrescriptionIssued";
                    } catch {
                        return false;
                    }
                });

                if (eventLog) {
                    const parsed = doctorContract.interface.parseLog(eventLog);
                    if (parsed?.args?.[0] != null) {
                        prescriptionId = parsed.args[0].toString();
                    }
                }
            } catch (error) {
                console.error("Error parsing event logs:", error);
            }

            // Update the patient record with blockchain data
            patient.prescriptionId = prescriptionId;
            patient.txHash = actualTxHash;
            await patient.save();

            console.log("✅ Patient updated with prescriptionId:", prescriptionId, "and txHash:", actualTxHash);

            const qrData = JSON.stringify({
                prescriptionId,
                patientId,
                verificationUrl: `${BASE_URL}/api/prescription/verify-qr/${prescriptionId}`
            });
            const qrCodeDataURL = await generateQRCode(qrData);

            const prescriptionDetails = await adminContract.verifyPrescription(Number(prescriptionId));

            const pdfFilename = await generatePrescriptionPDF(
                patient,
                {
                    doctor: prescriptionDetails[2].doctor,
                    doctorName: user.fullName,
                    medicalRegNo: user.medicalRegNo,
                    specialization: user.specialization,
                    medicines: medicineArray,
                    dosages: dosageArray,
                    consultationDate: prescriptionDetails[2].consultationDate,
                    expiryDate: prescriptionDetails[2].expiryDate
                },
                qrCodeDataURL
            );

            return res.status(201).json({
                success: true,
                status: "issued",
                prescriptionId,
                txHash: actualTxHash,
                patient,
                qrCode: qrCodeDataURL,
                pdfUrl: `${BASE_URL}/pdfs/${pdfFilename}`,
                downloadUrl: `${BASE_URL}/api/prescription/${prescriptionId}/download`,
                uploadedFile: req.file ? `${BASE_URL}/uploads/${req.file.filename}` : null,
                issuedBy: {
                    doctorName: user.fullName,
                    medicalRegNo: user.medicalRegNo,
                    specialization: user.specialization,
                    role: user.role
                }
            });
        } catch (err: any) {
            console.error("❌ Issue error:", err);

            if (err.code === 11000) {
                return res.status(409).json({ error: "Patient ID already exists" });
            }
            if (err.code === "CALL_EXCEPTION") {
                return res.status(403).json({
                    error: "Not authorized as doctor or invalid contract call",
                    details: err.reason || err.message,
                });
            }

            return res.status(500).json({
                error: "Internal server error",
                details: err.message
            });
        }
    });
// ==================== PUBLIC ROUTES (No Auth Required) ====================

// QR Code verification endpoint for pharmacy scanning
app.get("/api/prescription/verify-qr/:id", async (req, res) => {
    try {
        const prescriptionId = Number(req.params.id);

        if (isNaN(prescriptionId) || prescriptionId <= 0) {
            return res.status(400).json({ error: "Invalid prescription ID" });
        }

        const data = await adminContract.verifyPrescription(prescriptionId);

        if (!data[0]) {
            return res.status(404).json({ error: "Prescription not found or invalid" });
        }

        const patient = await Patient.findOne({ prescriptionId: prescriptionId.toString() });

        const medicines = await adminContract.getPrescriptionMedicines(prescriptionId);
        const dosages = await adminContract.getPrescriptionDosages(prescriptionId);

        return res.json({
            success: true,
            valid: true,
            prescription: {
                id: prescriptionId,
                ...bigintToString(data[2]),
                medicines,
                dosages
            },
            patient: patient ? {
                name: patient.name,
                patientId: patient.patientId,
                age: patient.age,
                gender: patient.gender,
                address: patient.address
            } : null,
            isDispensed: data[1],
            canDispense: data[0] && !data[1]
        });
    } catch (err: any) {
        console.error("❌ QR Verify error:", err);
        return res.status(500).json({
            error: "Failed to verify prescription",
            details: err.message
        });
    }
});

// Download PDF prescription
app.get("/api/prescription/:id/download", async (req, res) => {
    try {
        const prescriptionId = req.params.id;
        const filename = `prescription-${prescriptionId}.pdf`;
        const filepath = path.join("pdfs", filename);

        try {
            await fs.access(filepath);
        } catch {
            return res.status(404).json({ error: "PDF not found" });
        }

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.sendFile(path.resolve(filepath));
    } catch (err: any) {
        console.error("❌ Download error:", err);
        return res.status(500).json({
            error: "Failed to download prescription",
            details: err.message
        });
    }
});

// Get patient prescription with QR code
app.get("/api/patient/:patientId/prescription", async (req, res) => {
    try {
        const { patientId } = req.params;

        const patient = await Patient.findOne({ patientId });
        if (!patient) {
            return res.status(404).json({ error: "Patient not found" });
        }

        const qrData = JSON.stringify({
            prescriptionId: patient.prescriptionId,
            patientId: patient.patientId,
            verificationUrl: `${BASE_URL}/api/prescription/verify-qr/${patient.prescriptionId}`
        });
        const qrCodeDataURL = await generateQRCode(qrData);

        return res.json({
            success: true,
            patient,
            qrCode: qrCodeDataURL,
            pdfUrl: `${BASE_URL}/pdfs/prescription-${patient.prescriptionId}.pdf`,
            downloadUrl: `${BASE_URL}/api/prescription/${patient.prescriptionId}/download`
        });
    } catch (err: any) {
        console.error("❌ Get patient prescription error:", err);
        return res.status(500).json({
            error: "Failed to get patient prescription",
            details: err.message
        });
    }
});

app.post("/api/prescriptions/assign", (req: Request, res: Response) => {
    try {
        const { doctorId, patientId, medicineList, patientLat, patientLon } = req.body;

        if (!doctorId || !patientId || !medicineList || !patientLat || !patientLon) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        // Step 1: Find nearest pharmacy
        let nearestPharmacy = pharmacies[0];
        let minDistance = calculateDistance(patientLat, patientLon, pharmacies[0].latitude, pharmacies[0].longitude);

        pharmacies.forEach((pharmacy) => {
            const distance = calculateDistance(patientLat, patientLon, pharmacy.latitude, pharmacy.longitude);
            if (distance < minDistance) {
                minDistance = distance;
                nearestPharmacy = pharmacy;
            }
        });

        // Step 2: Create prescription and assign it
        const newPrescription = {
            id: `RX${Date.now()}`,
            doctorId,
            patientId,
            medicineList,
            assignedPharmacyId: nearestPharmacy.id,
            createdAt: new Date(),
            status: "pending" // pending → accepted → dispensed
        };

        prescriptions.push(newPrescription);

        return res.status(201).json({
            message: "Prescription assigned to nearest pharmacy",
            prescription: newPrescription,
            nearestPharmacy,
        });
    } catch (error: any) {
        return res.status(500).json({ message: "Internal Server Error", error: error.message });
    }
});

/**
 * GET /api/pharmacy/:pharmacyId/prescriptions
 * Pharmacy fetches all prescriptions assigned to them
 */
app.get("/api/pharmacy/:pharmacyId/prescriptions", (req: Request, res: Response) => {
    const { pharmacyId } = req.params;

    const assignedPrescriptions = prescriptions.filter(
        (prescription) => prescription.assignedPharmacyId === pharmacyId
    );

    return res.json({
        message: `Prescriptions for pharmacy ${pharmacyId}`,
        prescriptions: assignedPrescriptions,
    });
});

// Health check
app.get("/api/health", (req, res) => {
    res.json({
        status: "healthy",
        timestamp: new Date().toISOString(),
        mongodb: mongoose.connection.readyState === 1 ? "connected" : "disconnected",
    });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error("Unhandled error:", err);
    res.status(500).json({ error: "Internal server error" });
});

// 404 fallback
app.use((req, res) => {
    res.status(404).json({ error: "Route not found" });
});

// Start server
const port = Number(process.env.PORT || 4000);
app.listen(port, () => {
    console.log(`🚀 Backend running at http://localhost:${port}`);
    console.log(`📋 Health check: http://localhost:${port}/api/health`);
    console.log(`🔐 Doctor Register: POST http://localhost:${port}/api/doctor/register`);
    console.log(`🔑 Doctor Login: POST http://localhost:${port}/api/doctor/login`);
});