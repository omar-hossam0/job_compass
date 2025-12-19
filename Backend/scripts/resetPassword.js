import mongoose from "mongoose";
import User from "../models/User.js";

// Usage: node scripts/resetPassword.js email@example.com newpassword

const email = process.argv[2];
const newPassword = process.argv[3] || "password123";

if (!email) {
    console.log("❌ Please provide an email address");
    console.log("Usage: node scripts/resetPassword.js email@example.com [password]");
    process.exit(1);
}

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        const user = await User.findOne({ email });

        if (!user) {
            console.log(`❌ User not found: ${email}`);
            process.exit(1);
        }

        // Update password (triggers pre-save hook for hashing)
        user.password = newPassword;
        await user.save();

        console.log("✅ Password reset successfully!");
        console.log("Email:", user.email);
        console.log("Name:", user.name);
        console.log("Role:", user.role);
        console.log("New Password:", newPassword);

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
