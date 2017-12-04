const router = require('express').Router();
const db = require('../../db/store');
const controller = require('./drinkController')(db);

// get /drinks
router.route('/').get(controller.list);

module.exports = router;