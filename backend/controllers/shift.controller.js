const Shift = require('../models/shift.model');
const Agent = require('../models/agent.model');

exports.getAllShifts = async (req, res) => {
  try {
    const shifts = await Shift.find().populate('agentId');
    res.json(shifts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getAgentShifts = async (req, res) => {
  try {
    const shifts = await Shift.find({ agentId: req.params.agentId });
    if (!shifts) {
      return res.status(404).json({ message: 'No shifts found' });
    }
    res.json(shifts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.createShift = async (req, res) => {
  const shift = new Shift({
    agentId: req.body.agentId,
    startTime: req.body.startTime,
    endTime: req.body.endTime,
    weekdays: req.body.weekdays
  });

  try {
    const newShift = await shift.save();
    res.status(201).json(newShift);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateShift = async (req, res) => {
  try {
    const shift = await Shift.findById(req.params.id);
    if (!shift) {
      return res.status(404).json({ message: 'Shift not found' });
    }
    
    Object.assign(shift, req.body);
    const updatedShift = await shift.save();
    res.json(updatedShift);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.deleteShift = async (req, res) => {
  try {
    const shift = await Shift.findById(req.params.id);
    if (!shift) {
      return res.status(404).json({ message: 'Shift not found' });
    }
    await shift.remove();
    res.json({ message: 'Shift deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};