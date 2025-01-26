const express = require('express');
const router = express.Router();
const Agent = require('../models/Agent');

// Get all agents
router.get('/', async (req, res, next) => {
  try {
    const agents = await Agent.find().populate('currentTickets');
    res.json(agents);
  } catch (err) {
    next(err);
  }
});

// Create agent
router.post('/', async (req, res, next) => {
  try {
    const agent = new Agent(req.body);
    await agent.save();
    res.status(201).json(agent);
  } catch (err) {
    next(err);
  }
});

// Update agent status
router.put('/:id/status', async (req, res, next) => {
  try {
    const { isOnline } = req.body;
    const agent = await Agent.findByIdAndUpdate(
      req.params.id,
      { isOnline },
      { new: true }
    );
    if (!agent) return res.status(404).json({ message: 'Agent not found' });
    res.json(agent);
  } catch (err) {
    next(err);
  }
});

module.exports = router;