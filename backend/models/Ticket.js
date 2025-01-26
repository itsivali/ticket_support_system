const mongoose = require('mongoose');

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
    required: [true, 'Estimated hours is required'],
    min: [0, 'Estimated hours must be positive']
  },
  status: {
    type: String,
    enum: ['PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED'],
    default: 'PENDING'
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agent'
  },
  priority: {
    type: String,
    enum: ['LOW', 'MEDIUM', 'HIGH'],
    default: 'MEDIUM'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Ticket', ticketSchema);