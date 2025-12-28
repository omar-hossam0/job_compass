import mongoose from "mongoose";
import User from "../models/User.js";

const fixBaUser = async () => {
  try {
    await mongoose.connect("mongodb://localhost:27017/cv_project_db");
    console.log("✅ Connected to database");

    const result = await User.updateOne(
      { email: "ba@gmail.com" },
      { $set: { role: "employee" } }
    );

    console.log(`✅ Updated user 'ba' - Modified: ${result.modifiedCount}`);

    const user = await User.findOne({ email: "ba@gmail.com" });
    console.log("Updated user:", user);

    await mongoose.connection.close();
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
};

fixBaUser();
