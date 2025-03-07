const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());

const MONGO_URI = 'mongodb://localhost:27017';
const DB_NAME = 'ticket_support_system';

let db;
MongoClient.connect(MONGO_URI, { useUnifiedTopology: true })
  .then(client => {
    console.log('Connected to MongoDB');
    db = client.db(DB_NAME);
  })
  .catch(error => console.error(error));

// Agents endpoints
app.get('/agents', async (req, res) => {
  try {
    const agents = await db.collection('agents').find({}).toArray();
    res.json(agents);
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
});

app.post('/agents', async (req, res) => {
  try {
    const agent = req.body;
    const result = await db.collection('agents').insertOne(agent);
    res.json({ id: result.insertedId });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
});

// Tickets endpoints
app.get('/tickets', async (req, res) => {
  try {
    const tickets = await db.collection('tickets').find({}).toArray();
    res.json(tickets);
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
});

app.post('/tickets', async (req, res) => {
  try {
    const ticket = req.body;
    const result = await db.collection('tickets').insertOne(ticket);
    res.json({ id: result.insertedId });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
});

// Example endpoint to update ticket (e.g., assign an agent)
app.patch('/tickets/:id', async (req, res) => {
  try {
    const ticketId = req.params.id;
    const update = req.body;
    await db.collection('tickets').updateOne(
      { _id: new ObjectId(ticketId) },
      { $set: update }
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
});

app.listen(PORT, () => {
  console.log(`API server running on port ${PORT}`);
});