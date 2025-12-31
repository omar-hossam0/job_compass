import mongoose from "mongoose";

const applicationSchema = new mongoose.Schema(
  {
    jobId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Job",
      required: true,
    },
    candidateId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Candidate",
      required: true,
    },
    // Basic required information
    basicInfo: {
      fullName: {
        type: String,
        required: [true, "الاسم الكامل مطلوب"],
        trim: true,
        minlength: [3, "الاسم يجب أن يكون 3 أحرف على الأقل"],
        maxlength: [100, "الاسم لا يمكن أن يتجاوز 100 حرف"],
      },
      phoneNumber: {
        type: String,
        required: [true, "رقم التليفون مطلوب"],
        match: [
          /^(\+20|0)?1[0125]\d{8}$/,
          "يرجى إدخال رقم تليفون مصري صحيح",
        ],
      },
      region: {
        type: String,
        required: [true, "المنطقة مطلوبة"],
        trim: true,
        minlength: [2, "المنطقة يجب أن تكون حرفين على الأقل"],
      },
      address: {
        type: String,
        required: [true, "العنوان مطلوب"],
        trim: true,
        minlength: [10, "العنوان يجب أن يكون 10 أحرف على الأقل"],
      },
      expectedSalary: {
        type: Number,
        required: [true, "السالري المتوقع مطلوب"],
        min: [0, "السالري لا يمكن أن يكون سالب"],
      },
    },
    // Custom question answers (if HR added any)
    customAnswers: [
      {
        question: {
          type: String,
          required: [true, "السؤال مطلوب"],
        },
        answer: {
          type: String,
          required: [true, "الإجابة مطلوبة"],
          maxlength: [1000, "الإجابة لا يمكن أن تتجاوز 1000 حرف"],
        },
      },
    ],
    status: {
      type: String,
      enum: ["Pending", "Reviewed", "Shortlisted", "Rejected", "Accepted"],
      default: "Pending",
    },
    appliedAt: {
      type: Date,
      default: Date.now,
    },
    reviewedAt: {
      type: Date,
    },
    hrNotes: {
      type: String,
      maxlength: [500, "الملاحظات لا يمكن أن تتجاوز 500 حرف"],
    },
  },
  {
    timestamps: true,
  }
);

// Prevent duplicate applications
applicationSchema.index({ jobId: 1, candidateId: 1 }, { unique: true });

export default mongoose.model("Application", applicationSchema);
