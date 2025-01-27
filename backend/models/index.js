const mongoose = require('mongoose');

// Define schemas
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
  }
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

// Create and export models
module.exports = {
  Ticket: mongoose.model('Ticket', ticketSchema),
  Agent: mongoose.model('Agent', agentSchema)
};