import express from "express";
import {
  getOrCreateChat,
  sendMessage,
  getChatMessages,
  getHRChats,
  getCandidateChats,
  updateApplicationStatus,
} from "../controllers/chatController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

// All routes require authentication
router.use(protect);

// Create or get existing chat
router.post("/start", getOrCreateChat);

// Get all chats for HR
router.get("/hr", getHRChats);

// Get all chats for candidate
router.get("/candidate", getCandidateChats);

// Get messages for a specific chat
router.get("/:chatId", getChatMessages);

// Send a message
router.post("/:chatId/message", sendMessage);

// Update application status (approve/reject)
router.put("/application/:candidateId/:jobId/status", updateApplicationStatus);

export default router;
