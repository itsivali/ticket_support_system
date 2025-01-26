const mongoose = require('mongoose');

const agentSchema = new mongoose.Schema({
  name: String,
  email: String,
  isOnline: Boolean,
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

