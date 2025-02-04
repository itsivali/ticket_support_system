const express = require('express');
const router = express.Router();
const shiftController = require('../controllers/shift.controller');

// Get all shifts
router.get('/', shiftController.getAllShifts);

// Get shifts for a specific agent
router.get('/:agentId', shiftController.getAgentShifts);

// Create a new shift
router.post('/', shiftController.createShift);

// Update a shift
router.put('/:id', shiftController.updateShift);

// Delete a shift
router.delete('/:id', shiftController.deleteShift);

module.exports = router;