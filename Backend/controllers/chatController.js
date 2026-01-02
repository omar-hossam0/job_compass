import Chat from "../models/Chat.js";
import Application from "../models/Application.js";
import Candidate from "../models/Candidate.js";
import Job from "../models/Job.js";
import Notification from "../models/Notification.js";
import User from "../models/User.js";

// Get or create a chat between HR and candidate for a job
export const getOrCreateChat = async (req, res) => {
  try {
    const { candidateId, jobId } = req.body;
    const hrId = req.user.id;

    // Check if chat already exists
    let chat = await Chat.findOne({
      hrId: hrId,
      candidateId: candidateId,
      jobId: jobId,
    });

    if (!chat) {
      // Get the application
      const application = await Application.findOne({
        candidateId: candidateId,
        jobId: jobId,
      });

      // Create new chat
      chat = await Chat.create({
        hrId: hrId,
        candidateId: candidateId,
        jobId: jobId,
        applicationId: application?._id || null,
        messages: [],
        status: "active",
      });

      // Update application status to interviewing
      if (application) {
        application.status = "Interviewing";
        await application.save();
      }

      // Get candidate's user info
      const candidate = await Candidate.findById(candidateId);
      const job = await Job.findById(jobId);

      // Send notification to candidate
      if (candidate && candidate.user) {
        await Notification.create({
          userId: candidate.user,
          title: "Interview Request",
          message: `You have been shortlisted for ${job?.title || "a position"}! The HR wants to chat with you.`,
          type: "interview",
          read: false,
          metadata: {
            chatId: chat._id,
            jobId: jobId,
            hrId: hrId,
          },
        });
      }
    }

    // Populate chat details
    const populatedChat = await Chat.findById(chat._id)
      .populate("candidateId", "name email photo")
      .populate("jobId", "title");

    res.json({
      success: true,
      data: {
        id: populatedChat._id,
        candidateName: populatedChat.candidateId?.name || "Unknown",
        candidatePhoto: populatedChat.candidateId?.photo || null,
        jobTitle: populatedChat.jobId?.title || "Unknown Job",
        messages: populatedChat.messages.map((msg) => ({
          id: msg._id,
          senderId: msg.senderId,
          senderRole: msg.senderRole,
          content: msg.content,
          createdAt: msg.createdAt,
          readAt: msg.readAt,
        })),
        status: populatedChat.status,
        lastMessageAt: populatedChat.lastMessageAt,
      },
    });
  } catch (error) {
    console.error("Get/Create Chat Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Send a message in a chat
export const sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { content } = req.body;
    const userId = req.user.id;
    const userRole = req.user.role;

    const chat = await Chat.findById(chatId);

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found",
      });
    }

    // Verify user is part of this chat
    const isHR = chat.hrId.toString() === userId;
    const candidate = await Candidate.findById(chat.candidateId);
    const isCandidate = candidate?.user?.toString() === userId;

    if (!isHR && !isCandidate) {
      return res.status(403).json({
        success: false,
        message: "Not authorized to send messages in this chat",
      });
    }

    // Add message
    const message = {
      senderId: userId,
      senderRole: isHR ? "hr" : "candidate",
      content: content,
    };

    chat.messages.push(message);
    chat.lastMessageAt = new Date();
    await chat.save();

    // Get the newly added message
    const newMessage = chat.messages[chat.messages.length - 1];

    // Send notification to the other party
    const recipientId = isHR ? candidate?.user : chat.hrId;
    if (recipientId) {
      await Notification.create({
        userId: recipientId,
        title: "New Message",
        message: `You have a new message: "${content.substring(0, 50)}${content.length > 50 ? "..." : ""}"`,
        type: "chat",
        read: false,
        metadata: {
          chatId: chat._id,
        },
      });
    }

    res.json({
      success: true,
      data: {
        id: newMessage._id,
        senderId: newMessage.senderId,
        senderRole: newMessage.senderRole,
        content: newMessage.content,
        createdAt: newMessage.createdAt,
      },
    });
  } catch (error) {
    console.error("Send Message Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get chat messages
export const getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user.id;

    const chat = await Chat.findById(chatId)
      .populate("candidateId", "name email photo")
      .populate("jobId", "title");

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found",
      });
    }

    // Verify user is part of this chat
    const isHR = chat.hrId.toString() === userId;
    const candidate = await Candidate.findById(chat.candidateId._id);
    const isCandidate = candidate?.user?.toString() === userId;

    if (!isHR && !isCandidate) {
      return res.status(403).json({
        success: false,
        message: "Not authorized to view this chat",
      });
    }

    // Mark messages as read
    const myRole = isHR ? "hr" : "candidate";
    const otherRole = isHR ? "candidate" : "hr";
    
    chat.messages.forEach((msg) => {
      if (msg.senderRole === otherRole && !msg.readAt) {
        msg.readAt = new Date();
      }
    });
    await chat.save();

    res.json({
      success: true,
      data: {
        id: chat._id,
        candidateId: chat.candidateId._id,
        candidateName: chat.candidateId?.name || "Unknown",
        candidatePhoto: chat.candidateId?.photo || null,
        jobId: chat.jobId._id,
        jobTitle: chat.jobId?.title || "Unknown Job",
        hrId: chat.hrId,
        messages: chat.messages.map((msg) => ({
          id: msg._id,
          senderId: msg.senderId,
          senderRole: msg.senderRole,
          content: msg.content,
          createdAt: msg.createdAt,
          readAt: msg.readAt,
          isMe: msg.senderId.toString() === userId,
        })),
        status: chat.status,
        lastMessageAt: chat.lastMessageAt,
      },
    });
  } catch (error) {
    console.error("Get Chat Messages Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get all chats for HR
export const getHRChats = async (req, res) => {
  try {
    const hrId = req.user.id;

    const chats = await Chat.find({ hrId: hrId })
      .populate("candidateId", "name email photo")
      .populate("jobId", "title")
      .sort({ lastMessageAt: -1 });

    res.json({
      success: true,
      count: chats.length,
      data: chats.map((chat) => ({
        id: chat._id,
        candidateId: chat.candidateId?._id,
        candidateName: chat.candidateId?.name || "Unknown",
        candidatePhoto: chat.candidateId?.photo || null,
        jobId: chat.jobId?._id,
        jobTitle: chat.jobId?.title || "Unknown Job",
        lastMessage: chat.messages.length > 0 
          ? chat.messages[chat.messages.length - 1].content 
          : null,
        lastMessageAt: chat.lastMessageAt,
        unreadCount: chat.messages.filter(
          (msg) => msg.senderRole === "candidate" && !msg.readAt
        ).length,
        status: chat.status,
      })),
    });
  } catch (error) {
    console.error("Get HR Chats Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get all chats for Candidate
export const getCandidateChats = async (req, res) => {
  try {
    const userId = req.user.id;

    // Find candidate by user id
    const candidate = await Candidate.findOne({ user: userId });

    if (!candidate) {
      return res.json({
        success: true,
        count: 0,
        data: [],
      });
    }

    const chats = await Chat.find({ candidateId: candidate._id })
      .populate("hrId", "name email profileImage")
      .populate("jobId", "title companyLogo")
      .sort({ lastMessageAt: -1 });

    res.json({
      success: true,
      count: chats.length,
      data: chats.map((chat) => ({
        id: chat._id,
        hrId: chat.hrId?._id,
        hrName: chat.hrId?.name || "HR Manager",
        hrPhoto: chat.hrId?.profileImage || null,
        jobId: chat.jobId?._id,
        jobTitle: chat.jobId?.title || "Unknown Job",
        companyLogo: chat.jobId?.companyLogo || null,
        lastMessage: chat.messages.length > 0 
          ? chat.messages[chat.messages.length - 1].content 
          : null,
        lastMessageAt: chat.lastMessageAt,
        unreadCount: chat.messages.filter(
          (msg) => msg.senderRole === "hr" && !msg.readAt
        ).length,
        status: chat.status,
      })),
    });
  } catch (error) {
    console.error("Get Candidate Chats Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Update application status (Approve/Reject after interview)
export const updateApplicationStatus = async (req, res) => {
  try {
    const { candidateId, jobId } = req.params;
    const { status, notes } = req.body;
    const hrId = req.user.id;

    // Validate status
    const validStatuses = ["Pending", "Reviewed", "Shortlisted", "Interviewing", "Accepted", "Rejected"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(", ")}`,
      });
    }

    // Find the application
    const application = await Application.findOne({
      candidateId: candidateId,
      jobId: jobId,
    });

    if (!application) {
      return res.status(404).json({
        success: false,
        message: "Application not found",
      });
    }

    // Update application
    application.status = status;
    if (notes) {
      application.hrNotes = notes;
    }
    application.reviewedBy = hrId;
    application.reviewedAt = new Date();
    await application.save();

    // Get candidate info for notification
    const candidate = await Candidate.findById(candidateId);
    const job = await Job.findById(jobId);

    // Send notification to candidate
    if (candidate && candidate.user) {
      let notificationMessage = "";
      let notificationType = "application";

      if (status === "Accepted") {
        notificationMessage = `🎉 Congratulations! You have been accepted for the position of ${job?.title || "the job"}!`;
        notificationType = "accepted";
      } else if (status === "Rejected") {
        notificationMessage = `We regret to inform you that your application for ${job?.title || "the position"} was not successful.`;
        notificationType = "rejected";
      } else if (status === "Shortlisted") {
        notificationMessage = `Good news! You have been shortlisted for ${job?.title || "the position"}.`;
        notificationType = "shortlisted";
      } else if (status === "Interviewing") {
        notificationMessage = `You have been selected for an interview for ${job?.title || "the position"}.`;
        notificationType = "interview";
      }

      if (notificationMessage) {
        await Notification.create({
          userId: candidate.user,
          title: `Application ${status}`,
          message: notificationMessage,
          type: notificationType,
          read: false,
          metadata: {
            jobId: jobId,
            applicationId: application._id,
            status: status,
          },
        });
      }
    }

    // Close chat if accepted or rejected
    if (status === "Accepted" || status === "Rejected") {
      await Chat.findOneAndUpdate(
        { hrId: hrId, candidateId: candidateId, jobId: jobId },
        { status: "closed" }
      );
    }

    res.json({
      success: true,
      message: `Application ${status.toLowerCase()} successfully`,
      data: {
        applicationId: application._id,
        status: application.status,
        reviewedAt: application.reviewedAt,
      },
    });
  } catch (error) {
    console.error("Update Application Status Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
