const router = require('express').Router();
const Notification = require('../../notification')
const { execProcedure } = require('../../dataBase');

router.get('/', async (req, res) => {
    const callback =  function(returnObject){
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if (returnObject.data) {
            if (Array.isArray(returnObject.data)) {
                returnObject.data = { notifications: returnObject.data }
            } else {
                returnObject.data = { notifications: [returnObject.data] }
            }
        } else {
            returnObject.data = { notifications: [] }
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_notificationAllGet', { }, req.idUser, callback);
});

router.delete('/:id', [
], async (req, res) => {
    Notification.deleteNotification(req.params.id, req.idUser)
        .then(() => {
            return res.status(200).json({ status: 200 })
        })
        .catch((err) => {
            console.log(err)
            return res.status(500).json({ status: -11, error: "Internal error" })
        })
});

module.exports = router;