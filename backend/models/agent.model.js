const mongoose = require('mongoose');

const agentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  role: {
    type: String,
    required: true,
    enum: ['SUPPORT', 'SUPERVISOR', 'ADMIN'],
    default: 'SUPPORT'
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  isOnline: {
    type: Boolean,
    default: false
  },
  currentTickets: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ticket'
  }],
  shiftSchedule: {
    startTime: Date,
    endTime: Date,
    weekdays: [Number] // 0-6 for Sunday-Saturday
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Agent', agentSchema);