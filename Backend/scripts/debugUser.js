import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        const user = await User.findOne({ email: "baraawael7901@gmail.com" }).select("+password");

        if (!user) {
            console.log("❌ User not found");
            process.exit(1);
        }

        console.log("✅ User found!");
        console.log("Name:", user.name);
        console.log("Email:", user.email);
        console.log("Role:", user.role);
        console.log("Hashed Password (first 50 chars):", user.password.substring(0, 50));
        console.log("\n🔍 Testing password comparison:");

        // Test if password matches
        const isMatch = await user.comparePassword("password123");
        console.log("password123 matches?", isMatch);

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
