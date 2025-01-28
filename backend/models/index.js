const mongoose = require('mongoose');

// Ticket Schema
const ticketSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    trim: true,
    minlength: [3, 'Title must be at least 3 characters']
  },
  description: {
    type: String,
    required: [true, 'Description is required'],
    minlength: [10, 'Description must be at least 10 characters']
  },
  dueDate: {
    type: Date,
    required: [true, 'Due date is required'],
    validate: {
      validator: function(v) {
        return v > new Date();
      },
      message: 'Due date must be in the future'
    }
  },
  estimatedHours: {
    type: Number,
    required: [true, 'Estimated hours is required'],
    min: [0.5, 'Estimated hours must be at least 0.5'],
    max: [24, 'Estimated hours cannot exceed 24']
  },
  status: {
    type: String,
    enum: ['OPEN', 'IN_PROGRESS', 'CLOSED'],
    default: 'OPEN'
  },
  priority: {
    type: String,
    enum: ['LOW', 'MEDIUM', 'HIGH'],
    default: 'MEDIUM'
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agent',
    default: null
  },
  comments: [{
    text: {
      type: String,
      required: true
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Agent',
      required: true
    },
    timestamp: {
      type: Date,
      default: Date.now
    }
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
});

// Pre-save middleware to update lastUpdated
ticketSchema.pre('save', function(next) {
  this.lastUpdated = new Date();
  next();
});

// Virtual for time spent
ticketSchema.virtual('timeSpent').get(function() {
  if (this.status === 'CLOSED') {
    return (this.lastUpdated - this.createdAt) / (1000 * 60 * 60); // Hours
  }
  return null;
});

// Instance methods
ticketSchema.methods = {
  addComment(text, authorId) {
    if (!text || !authorId) {
      throw new Error('Comment text and author ID are required');
    }
    this.comments.push({ text, author: authorId });
    return this.save();
  },

  assignToAgent(agentId) {
    if (!agentId) {
      throw new Error('Agent ID is required');
    }
    this.assignedTo = agentId;
    this.status = 'IN_PROGRESS';
    return this.save();
  },

  closeTicket() {
    if (this.status === 'CLOSED') {
      throw new Error('Ticket is already closed');
    }
    this.status = 'CLOSED';
    return this.save();
  }
};

// Create indexes
ticketSchema.index({ status: 1, priority: 1 });
ticketSchema.index({ assignedTo: 1 });
ticketSchema.index({ createdAt: -1 });

const agentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true
  },
  role: {
    type: String,
    enum: ['SUPPORT', 'SUPERVISOR'],
    default: 'SUPPORT'
  },
  isAvailable: {
    type: Boolean,
    default: true
  }
});

// Create and export models
const Ticket = mongoose.models.Ticket || mongoose.model('Ticket', ticketSchema);
const Agent = mongoose.models.Agent || mongoose.model('Agent', agentSchema);

module.exports = {
  Ticket,
  Agent
};