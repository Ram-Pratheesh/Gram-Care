import mongoose, { Schema, Document } from "mongoose";
import bcrypt from "bcryptjs";

export interface IPatientAccount extends Document {
    fullName: string;
    dob: string;
    gender?: 'Male' | 'Female' | 'Other';
    address: string;
    primaryPhone: string;
    altPhone?: string;
    email?: string;
    govId: string;
    language?: string;
    emergencyName: string;
    emergencyPhone: string;
    conditions?: string;
    allergies?: string;
    chronicMeds?: string;
    vitals?: string;
    bloodGroup?: string;
    pharmacy?: string;
    primaryDoctor?: string;
    consentTreatment?: string;
    consentResearch?: string;
    insuranceProvider?: string;
    policyNumber?: string;
    device?: string;
    lastSync?: string;
    username: string;
    password: string;
    agreePolicy: boolean;
    patientId: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    comparePassword(password: string): Promise<boolean>;
}

const PatientAccountSchema: Schema = new Schema({
    fullName: { type: String, required: true, minlength: 2, maxlength: 120 },
    dob: { type: String, required: true },
    gender: { type: String, enum: ['Male', 'Female', 'Other'], default: null },
    address: { type: String, required: true, minlength: 4, maxlength: 500 },
    primaryPhone: { type: String, required: true, minlength: 7, maxlength: 20 },
    altPhone: { type: String, default: null },
    email: { type: String, default: null },
    govId: { type: String, required: true, minlength: 3, maxlength: 80 },
    language: { type: String, maxlength: 40, default: null },
    emergencyName: { type: String, required: true, minlength: 2, maxlength: 120 },
    emergencyPhone: { type: String, required: true, minlength: 7, maxlength: 20 },
    conditions: { type: String, default: null },
    allergies: { type: String, default: null },
    chronicMeds: { type: String, default: null },
    vitals: { type: String, default: null },
    bloodGroup: { type: String, default: null },
    pharmacy: { type: String, default: null },
    primaryDoctor: { type: String, default: null },
    consentTreatment: { type: String, default: null },
    consentResearch: { type: String, default: null },
    insuranceProvider: { type: String, default: null },
    policyNumber: { type: String, default: null },
    device: { type: String, default: null },
    lastSync: { type: String, default: null },
    username: { type: String, required: true, unique: true, minlength: 3, maxlength: 120 }, // Changed from 'login' to 'username'
    password: { type: String, required: true, minlength: 6, maxlength: 200 },
    agreePolicy: { type: Boolean, required: true, default: true },
    patientId: { type: String, required: true, unique: true },
    isActive: { type: Boolean, default: true },
}, { timestamps: true });

// Hash password before saving
PatientAccountSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();
    const saltRounds = 12;
    this.password = await bcrypt.hash(this.password as string, saltRounds);
    next();
});

// Compare password method
PatientAccountSchema.methods.comparePassword = async function (password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
};

// Indexes for faster queries
PatientAccountSchema.index({ login: 1 });
PatientAccountSchema.index({ patientId: 1 });
PatientAccountSchema.index({ primaryPhone: 1 });

export default mongoose.model<IPatientAccount>("PatientAccount", PatientAccountSchema);