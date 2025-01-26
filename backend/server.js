const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const ticketRoutes = require('./routes/tickets');
const agentRoutes = require('./routes/agents');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/api/tickets', ticketRoutes);
app.use('/api/agents', agentRoutes);

mongoose.connect('mongodb://localhost/ticket_system');

app.listen(3000, () => {
  console.log('Server running on port 3000');
});