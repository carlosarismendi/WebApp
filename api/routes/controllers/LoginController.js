const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');
const moment = require('moment');
const jwt = require('jwt-simple');
const middleware = require('../middleware');

router.post('/', [
    check('user', 'Formato incorrecto').not().isEmpty(),
    check('password', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ error: "Missing necessary data" });
    }

    const callback  = function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -6) {
            return res.status(200).json(returnObject)
        }

        if (returnObject.status >= 0) {
            if (!bcryp.compareSync(req.body.password, returnObject.data.password)) {
                returnObject.status = -6;
                returnObject.data = null
                returnObject.error = "User and/or password are incorrect"
                return res.status(200).json(returnObject);
            }

            let token = createToken(returnObject.data.idUser);

            const callbackToken  = function(returnObjectToken){
                if(!returnObject) {
                    return res.status(500).json({ status: -11, error: "Internal error" })
                }

                returnObjectToken.data = {
                    jwtToken: token,
                    idUser: returnObject.data.idUser,
                    email: returnObject.data.email,
                    nickname: returnObject.data.nickname,
                    name: returnObject.data.name,
                    profileImage: returnObject.data.profileImage,
                    description: returnObject.data.description,
                    phone: returnObject.data.phone
                };

                return res.status(201).json(returnObjectToken);
            };

            execProcedure('usp_userTokenInsert', { token }, returnObject.data.idUser, callbackToken);
        } else{
            return res.json(returnObject);
        }
    };

    execProcedure('usp_loginGet', { user: req.body.user }, -2, callback);
});

router.delete('/', middleware.checkToken, async (req, res) => {
    const callback  = function(returnObject){
        if(!returnObject){
            return res.status(500).json({ error: "Error interno" });
        }

        return res.status(201).json(returnObject);
    };

    execProcedure('usp_loginDelete', {}, req.idUser, callback);
});

const createToken = (idUser) => {
    const payLoad = {
        idUser: idUser,
        exp: moment().add(100, 'years').valueOf()
    }

    return jwt.encode(payLoad, process.env.SECRET_KEY);
}

module.exports = router;