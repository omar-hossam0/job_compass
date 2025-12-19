import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        // Check if user exists
        let user = await User.findOne({ email: "baraawael7901@gmail.com" });

        if (user) {
            console.log("✅ User exists!");
            console.log("Name:", user.name);
            console.log("Email:", user.email);
            console.log("Role:", user.role);
        } else {
            console.log("⚠️ User doesn't exist, creating one...");

            // Create the user
            user = await User.create({
                name: "Baraawael",
                email: "baraawael7901@gmail.com",
                password: "password123", // User can change this later
                role: "user", // Employee role
                phone: "01000000001",
            });

            console.log("✅ User created successfully!");
            console.log("Email:", user.email);
            console.log("Password: password123");
            console.log("Role: user (Employee)");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
