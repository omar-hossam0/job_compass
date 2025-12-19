import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    try {
        console.log("✅ Connected to cv_project_db\n");

        // Get all users
        const users = await User.find({});

        console.log(`📊 Resetting passwords for ${users.length} users...\n`);

        const defaultPassword = "password123";

        for (const user of users) {
            // Update password (triggers pre-save hook for hashing)
            user.password = defaultPassword;
            await user.save();

            console.log(`✅ Reset password for: ${user.email}`);
            console.log(`   Name: ${user.name}`);
            console.log(`   Role: ${user.role}`);
            console.log(`   Password: ${defaultPassword}`);
            console.log('');
        }

        console.log("\n🎉 All passwords have been reset!");
        console.log("📝 All users can now login with:");
        console.log("   Password: password123\n");

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error.message);
        process.exit(1);
    }
});
