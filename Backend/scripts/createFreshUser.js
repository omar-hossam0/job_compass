import mongoose from "mongoose";
import User from "../models/User.js";
import bcrypt from "bcryptjs";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        // Delete existing user
        await User.deleteOne({ email: "baraawael7901@gmail.com" });
        console.log("🗑️ Deleted existing user");

        // Create fresh user with proper password
        const newUser = await User.create({
            name: "Baraa Wael",
            email: "baraawael7901@gmail.com",
            password: "password123", // Will be hashed by pre-save hook
            role: "user",
            phone: "01000000001",
        });

        console.log("\n✅ New user created!");
        console.log("Name:", newUser.name);
        console.log("Email:", newUser.email);
        console.log("Role:", newUser.role);

        // Verify by fetching and testing password
        const user = await User.findOne({ email: "baraawael7901@gmail.com" }).select("+password");
        const isMatch = await user.comparePassword("password123");

        console.log("\n🔑 Password verification:");
        console.log("Password matches?", isMatch);

        if (isMatch) {
            console.log("✨ User is ready to login!");
        } else {
            console.log("❌ Password verification failed!");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
