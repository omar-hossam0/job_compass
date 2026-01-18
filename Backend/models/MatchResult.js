import mongoose from "mongoose";

const matchResultSchema = new mongoose.Schema(
  {
    jobId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Job",
      required: true,
      index: true,
    },
    candidateId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Candidate",
      required: true,
      index: true,
    },
    matchScore: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    semanticScore: {
      type: Number,
      min: 0,
      max: 60,
    },
    keywordScore: {
      type: Number,
      min: 0,
      max: 40,
    },
    matchedSkills: {
      type: Number,
      default: 0,
    },
    totalSkills: {
      type: Number,
      default: 0,
    },
    criticalSkills: [String],
    matchedAt: {
      type: Date,
      default: Date.now,
    },
    matchMethod: {
      type: String,
      default: "hybrid_weighted_scoring",
    },
  },
  {
    timestamps: true,
  },
);

// Compound index for efficient queries
matchResultSchema.index({ jobId: 1, matchScore: -1 });
matchResultSchema.index({ candidateId: 1, matchScore: -1 });

// Static method to save or update match result
matchResultSchema.statics.saveMatchResult = async function (matchData) {
  const existingMatch = await this.findOne({
    jobId: matchData.jobId,
    candidateId: matchData.candidateId,
  });

  if (existingMatch) {
    // Update existing match
    Object.assign(existingMatch, matchData);
    existingMatch.matchedAt = new Date();
    return await existingMatch.save();
  } else {
    // Create new match
    return await this.create(matchData);
  }
};

// Static method to get top matches for a job
matchResultSchema.statics.getTopMatchesForJob = async function (
  jobId,
  limit = 10,
) {
  return await this.find({ jobId })
    .sort({ matchScore: -1 })
    .limit(limit)
    .populate("candidateId", "name email phone skills experience education")
    .lean();
};

const MatchResult = mongoose.model("MatchResult", matchResultSchema);

export default MatchResult;
