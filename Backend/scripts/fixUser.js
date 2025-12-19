import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        // Find the user
        let user = await User.findOne({ email: "baraawael7901@gmail.com" });

        if (!user) {
            console.log("❌ User not found");
            process.exit(1);
        }

        // Update password (this will trigger the pre-save hook that hashes the password)
        user.password = "password123";
        user.role = "user";
        await user.save();

        console.log("✅ User updated successfully!");
        console.log("Email:", user.email);
        console.log("Name:", user.name);
        console.log("Role:", user.role);
        console.log("Password: password123");
        console.log("\n✨ Now try logging in with these credentials!");

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
