import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        // Create a test employee user
        const testEmployee = await User.create({
            name: "Test Employee",
            email: "employee@test.com",
            password: "password123",
            role: "user",
            phone: "01000000000",
        });

        console.log("✅ Test Employee created successfully!");
        console.log("Email:", testEmployee.email);
        console.log("Password: password123");
        console.log("Role:", testEmployee.role);

        // Create a test HR user
        const testHR = await User.create({
            name: "Test HR",
            email: "hr@test.com",
            password: "password123",
            role: "hr",
            phone: "01100000000",
        });

        console.log("\n✅ Test HR created successfully!");
        console.log("Email:", testHR.email);
        console.log("Password: password123");
        console.log("Role:", testHR.role);

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
