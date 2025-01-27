const mongoose = require('mongoose');

// Define schemas
const ticketSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    trim: true
  },
  description: {
    type: String,
    required: [true, 'Description is required']
  },
  dueDate: {
    type: Date,
    required: [true, 'Due date is required']
  },
  estimatedHours: {
    type: Number,
    required: [true, 'Estimated hours is required']
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
    ref: 'Agent'
  },
  comments: [{
    text: String,
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Agent'
    },
    timestamp: {
      type: Date,
      default: Date.now
    }
  }]
});

const agentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true
  }
});

// Model methods
ticketSchema.methods = {
  addComment(text, authorId) {
    this.comments.push({ text, author: authorId });
    return this.save();
  },

  assignToAgent(agentId) {
    this.assignedTo = agentId;
    this.status = 'IN_PROGRESS';
    return this.save();
  }
};

// Create and export models
module.exports = {
  Ticket: mongoose.model('Ticket', ticketSchema),
  Agent: mongoose.model('Agent', agentSchema)
};