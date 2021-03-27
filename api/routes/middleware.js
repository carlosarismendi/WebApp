const jwt = require('jwt-simple');
const { execProcedure } = require('../dataBase');

const checkToken = (req, res, next) => {
    const header = req.header('Authorization');

    if(!header){
        return res.status(401).json({ status: -15, error: "Unauthorized access" });
    }

    const fields = header.split(' ')

    let token = (fields.length > 1 && header.startsWith('Bearer')) ? fields[1] : null

    if(!token){
        return res.status(401).json({ status: -15, error: "Unauthorized access" });
    }

    let payLoad;

    try{
        payLoad = jwt.decode(token, process.env.SECRET_KEY);
    } catch(ex){
        return res.status(400).json({ status: -14, error: "Token is not valid" });
    }

    // Actualizar caducidad del token
    const callbackToken  = function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if (returnObject.status < 0) {
            return res.status(401).json(returnObject);
        }

        req.idUser = payLoad.idUser;
        next();
    };

    execProcedure('usp_userTokenUpdate', { token: token }, payLoad.idUser, callbackToken);
};

module.exports = {
    checkToken: checkToken
};