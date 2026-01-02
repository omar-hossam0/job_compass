import mongoose from "mongoose";

const savedCandidateSchema = new mongoose.Schema(
    {
        hrId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        candidateId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Candidate",
            required: true,
        },
        jobId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Job",
        },
        notes: {
            type: String,
            default: "",
        },
        savedAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

// Compound index to ensure unique HR-Candidate pairs
savedCandidateSchema.index({ hrId: 1, candidateId: 1 }, { unique: true });

const SavedCandidate = mongoose.model("SavedCandidate", savedCandidateSchema);

export default SavedCandidate;
