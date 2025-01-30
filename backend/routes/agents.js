const express = require('express');
const router = express.Router();
const { Agent } = require('../models');

// Get all agents
router.get('/', async (req, res) => {
  try {
    const agents = await Agent.find();
    res.json(agents);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create new agent
router.post('/', async (req, res) => {
  try {
    const agent = new Agent({
      name: req.body.name,
      email: req.body.email,
      role: req.body.role,
      isAvailable: req.body.isAvailable
    });

    const newAgent = await agent.save();
    res.status(201).json(newAgent);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update agent
router.put('/:id', async (req, res) => {
  try {
    const updatedAgent = await Agent.findByIdAndUpdate(
      req.params.id,
      {
        name: req.body.name,
        email: req.body.email,
        role: req.body.role,
        isAvailable: req.body.isAvailable
      },
      { new: true }
    );
    
    if (!updatedAgent) {
      return res.status(404).json({ message: 'Agent not found' });
    }
    
    res.json(updatedAgent);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete agent
router.delete('/:id', async (req, res) => {
  try {
    const agent = await Agent.findByIdAndDelete(req.params.id);
    if (!agent) {
      return res.status(404).json({ message: 'Agent not found' });
    }
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;