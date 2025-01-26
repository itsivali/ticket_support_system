const mongoose = require('mongoose');

const agentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
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
    weekdays: [Number]
  }
});

module.exports = mongoose.model('Agent', agentSchema);

