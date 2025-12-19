import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        console.log("✅ Connected to cv_project_db\n");

        // Get all users from cv-users collection
        const users = await User.find({});

        console.log(`📊 Total Users in cv-users collection: ${users.length}\n`);

        if (users.length === 0) {
            console.log("⚠️ No users found in the database!");
        } else {
            console.log("📋 Available Users:\n");
            users.forEach((user, index) => {
                console.log(`${index + 1}. Name: ${user.name}`);
                console.log(`   Email: ${user.email}`);
                console.log(`   Role: ${user.role}`);
                console.log(`   Phone: ${user.phone || 'N/A'}`);
                console.log(`   Created: ${user.createdAt || 'N/A'}`);
                console.log('   ---');
            });

            console.log("\n✨ All these users can login to the app!");
            console.log("💡 Use their email and password to login");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
