const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');

router.get('/', async (req, res) => {
    const callback =  function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_privacyGet', { }, req.idUser, callback);
});


router.put('/', [
    check('idVisibilityTypeProfile', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    const callback =  function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(201).json(returnObject)
    }

    execProcedure('usp_privacyUpdate', req.body, req.idUser, callback);
});

module.exports = router;