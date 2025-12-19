import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        // Find and update the user
        const user = await User.findOneAndUpdate(
            { email: "baraawael7901@gmail.com" },
            {
                password: "password123",
                role: "user" // Change to 'user' so it navigates to StudentDashboard
            },
            { new: true }
        );

        if (user) {
            console.log("✅ User updated successfully!");
            console.log("Email:", user.email);
            console.log("Name:", user.name);
            console.log("Role:", user.role);
            console.log("Password reset to: password123");
        } else {
            console.log("❌ User not found");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
