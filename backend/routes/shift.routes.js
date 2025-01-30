const express = require('express');
const router = express.Router();
const shiftController = require('../controllers/shift.controller');

router.get('/', shiftController.getAllShifts);
router.get('/:agentId', shiftController.getAgentShifts);
router.post('/', shiftController.createShift);
router.put('/:id', shiftController.updateShift);
router.delete('/:id', shiftController.deleteShift);

module.exports = router;