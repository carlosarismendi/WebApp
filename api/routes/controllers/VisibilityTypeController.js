const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');

router.get('/', async (req, res) => {

    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_visibilityTypesGetAll', {}, -2, callback)
});

module.exports = router;