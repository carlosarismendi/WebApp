const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');
const jwt = require('jwt-simple')

async function confirmUserAccount (req, res) {
    try {
        let tokenDecode = Buffer.from(req.body.token, "base64").toString("ascii");
        let jsonData = JSON.parse(tokenDecode);

        if (!jsonData.idRegister || !jsonData.token) {
            return res.status(422).json({ status: -2, error: "Missing necessary data"});
        }

        const callback  = function(returnObject){
            if(!returnObject) {
                return res.status(500).json({ status: -11, error: "Internal error" })
            }

            if(returnObject.status === -5) {
                return res.status(404).json(returnObject)
            }

            if(returnObject.status === -13) {
                return res.status(200).json(returnObject)
            }

            return res.status(201).json(returnObject);
        };

        execProcedure('usp_registerUpdate', jsonData, -2, callback);
    } catch (error) {
        return res.status(400).json({ status: -14, error: "Token is not valid"});
    }
}

router.post('/', [
    check('email', 'Formato incorrecto').isEmail(),
    check('password', 'Campo obligatorio').not().isEmpty(),
    check('nickname', 'Campo obligatorio').not().isEmpty(),
    check('name', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);
    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    req.body.password = bcryp.hashSync(req.body.password, 10);

    const callback  = function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status < 0) {
            return res.status(409).json(returnObject)
        }

        const payload = {
            idUser: returnObject.data.idRegister
        }

        const token =  Buffer.from(JSON.stringify({ idRegister: returnObject.data.idRegister, token: returnObject.data.token})).toString("base64");

        req.body.token = token
        confirmUserAccount(req, res)

        // return res.status(201).json({
        //     status: returnObject.status,
        //     data: {
        //         token: token
        //     }
        // });
    };

    execProcedure('usp_registerCreate', req.body, -2, callback);
});

router.put('/', [
    check('token', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    confirmUserAccount(req, res)
});

router.delete('/:nickname', async (req, res) => {
    const callback  = function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        return res.status(201).json(returnObject);
    };

    execProcedure('usp_registerDelete', req.params, -2, callback);
});

module.exports = router;