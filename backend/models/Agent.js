const mongoose = require('mongoose');

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
});

module.exports = mongoose.model('Agent', agentSchema);