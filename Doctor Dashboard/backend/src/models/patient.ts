import mongoose, { Schema, Document } from "mongoose";

export interface IPatient extends Document {
    name: string;
    patientId: string;
    age: number;
    gender: string;
    address: string;
    prescriptionId?: string; // Optional - will be updated after blockchain transaction
    txHash?: string; // Optional - will be updated after blockchain transaction
    uploadedFile?: string; // Optional file upload from doctor
    createdAt: Date;
    updatedAt: Date;
}

const PatientSchema: Schema = new Schema(
    {
        name: { type: String, required: true },
        patientId: { type: String, required: true, unique: true },
        age: { type: Number, required: true },
        gender: { type: String, required: true },
        address: { type: String, required: true },
        prescriptionId: { type: String, default: "0" }, // Default value, will be updated
        txHash: { type: String, default: "pending" }, // Default value, will be updated
        uploadedFile: { type: String }, // Store filename if doctor uploads supporting document
    },
    { timestamps: true }
);

// Index for faster queries
PatientSchema.index({ prescriptionId: 1 });
PatientSchema.index({ patientId: 1 });

export default mongoose.model<IPatient>("Patient", PatientSchema);