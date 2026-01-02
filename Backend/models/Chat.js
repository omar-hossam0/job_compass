import mongoose from "mongoose";

const messageSchema = new mongoose.Schema(
  {
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    senderRole: {
      type: String,
      enum: ["hr", "candidate"],
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    readAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

const chatSchema = new mongoose.Schema(
  {
    // HR user
    hrId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    // Candidate user
    candidateId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Candidate",
      required: true,
    },
    // The job this chat is related to
    jobId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Job",
      required: true,
    },
    // Application reference
    applicationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Application",
    },
    // Chat messages
    messages: [messageSchema],
    // Chat status
    status: {
      type: String,
      enum: ["active", "closed", "archived"],
      default: "active",
    },
    // Last message timestamp for sorting
    lastMessageAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for unique HR-Candidate-Job chat
chatSchema.index({ hrId: 1, candidateId: 1, jobId: 1 }, { unique: true });

// Index for quick lookups
chatSchema.index({ hrId: 1, lastMessageAt: -1 });
chatSchema.index({ candidateId: 1, lastMessageAt: -1 });

const Chat = mongoose.model("Chat", chatSchema);

export default Chat;
