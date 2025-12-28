import mongoose from "mongoose";
import User from "../models/User.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
  try {
    console.log("✅ Connected to cv_project_db\n");
    
    // Update all users with role "user" to "employee"
    const result = await User.updateMany(
      { role: "user" },
      { $set: { role: "employee" } }
    );
    
    console.log(`✅ Updated ${result.modifiedCount} users from "user" to "employee"\n`);
    
    // Show updated users
    const users = await User.find({});
    console.log("📋 Current users:\n");
    users.forEach((user, index) => {
      console.log(`${index + 1}. ${user.name} (${user.email}) - Role: ${user.role}`);
    });

    process.exit(0);
  } catch (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }
});
