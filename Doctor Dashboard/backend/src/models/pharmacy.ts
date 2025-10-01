import mongoose, { Document, Schema } from "mongoose";
import bcrypt from "bcryptjs";

export interface IPharmacy extends Document {
    email: string;
    password: string;
    name: string;
    address: string;
    comparePassword(password: string): Promise<boolean>;
}

const PharmacySchema: Schema = new Schema(
    {
        email: { type: String, required: true, unique: true },
        password: { type: String, required: true },
        name: { type: String, required: true },
        address: { type: String, required: true },
    },
    {
        timestamps: true,
        collection: "pharmacies",
    }
);

PharmacySchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password as string, salt);
    next();
});

PharmacySchema.methods.comparePassword = async function (password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
};

export default mongoose.model<IPharmacy>("Pharmacy", PharmacySchema);
