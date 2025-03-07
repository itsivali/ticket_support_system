const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { MongoClient, ObjectId } = require('mongodb');
const notifier = require('node-notifier');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());

const MONGO_URI = 'mongodb://127.0.0.1:27017';
const DB_NAME = 'ticket_support_system';

let db;
MongoClient.connect(MONGO_URI, { useUnifiedTopology: true })
  .then(client => {
    console.log('Connected to MongoDB');
    db = client.db(DB_NAME);
  })
  .catch(error => console.error(error));

// ----------------------
// Agent Endpoints
// ----------------------

// Get All Agents
app.get('/agents', async (req, res) => {
  try {
    const agents = await db.collection('agents').find({}).toArray();
    res.json(agents);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// Create an Agent
app.post('/agents', async (req, res) => {
  try {
    const agent = req.body;
    const result = await db.collection('agents').insertOne(agent);
    notifier.notify({ title: 'Agent Created', message: 'Agent was created successfully.' });
    res.json({ id: result.insertedId, message: 'Agent created successfully.' });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// Update an Agent
app.patch('/agents/:id', async (req, res) => {
  try {
    const agentId = req.params.id;
    const update = req.body;
    const result = await db.collection('agents').updateOne(
      { _id: new ObjectId(agentId) },
      { $set: update }
    );
    if (result.modifiedCount > 0) {
      notifier.notify({ title: 'Agent Updated', message: 'Agent was updated successfully.' });
      res.json({ success: true, message: 'Agent updated successfully.' });
    } else {
      res.status(404).json({ error: 'Agent not found or no changes made.' });
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// Delete an Agent
app.delete('/agents/:id', async (req, res) => {
  try {
    const agentId = req.params.id;
    const result = await db.collection('agents').deleteOne({ _id: new ObjectId(agentId) });
    if (result.deletedCount > 0) {
      notifier.notify({ title: 'Agent Deleted', message: 'Agent was deleted successfully.' });
      res.json({ success: true, message: 'Agent deleted successfully.' });
    } else {
      res.status(404).json({ error: 'Agent not found.' });
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// ----------------------
// Ticket Endpoints
// ----------------------

// Get All Tickets
app.get('/tickets', async (req, res) => {
  try {
    const tickets = await db.collection('tickets').find({}).toArray();
    res.json(tickets);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// Create a Ticket
app.post('/tickets', async (req, res) => {
  try {
    const ticket = req.body;
    const result = await db.collection('tickets').insertOne(ticket);
    notifier.notify({ title: 'Ticket Created', message: 'Ticket was created successfully.' });
    res.json({ id: result.insertedId, message: 'Ticket created successfully.' });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// Update a Ticket (e.g., assign an agent or update details)
app.patch('/tickets/:id', async (req, res) => {
  try {
    const ticketId = req.params.id;
    const update = req.body;
    const result = await db.collection('tickets').updateOne(
      { _id: new ObjectId(ticketId) },
      { $set: update }
    );
    if (result.modifiedCount > 0) {
      notifier.notify({ title: 'Ticket Updated', message: 'Ticket was updated successfully.' });
      res.json({ success: true, message: 'Ticket updated successfully.' });
    } else {
      res.status(404).json({ error: 'Ticket not found or no changes made.' });
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

// Delete a Ticket
app.delete('/tickets/:id', async (req, res) => {
  try {
    const ticketId = req.params.id;
    const result = await db.collection('tickets').deleteOne({ _id: new ObjectId(ticketId) });
    if (result.deletedCount > 0) {
      notifier.notify({ title: 'Ticket Deleted', message: 'Ticket was deleted successfully.' });
      res.json({ success: true, message: 'Ticket deleted successfully.' });
    } else {
      res.status(404).json({ error: 'Ticket not found.' });
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.toString() });
  }
});

app.listen(PORT, () => {
  console.log(`API server running on port ${PORT}`);
});