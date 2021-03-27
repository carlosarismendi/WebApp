const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');
const Notification = require('../../notification')

router.post('/', [
    check('idUserFollowed', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -10) {
            return res.status(409).json(returnObject)
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        let notification = {
            userToken: returnObject.data.userTargetToken,
            idUserCreator: req.idUser,
            idUserTarget: req.body.idUserFollowed,
            idNotificationType: 2, // Follow type pending
            title: 'Follow request',
            message: '',
            image: returnObject.data.userCreatorProfileImage
        }

        if (returnObject.data.idRequestStatus == 2) { // Accepted follow request
            notification.message = `The user @${returnObject.data.userCreatorNickname} now follows you.`
            notification.idNotificationType = 3 // Follow type accepted
        } else {
            notification.message = `The user @${returnObject.data.userCreatorNickname} wants to follow you.`
        }

        Notification.sendPushToOneUser(notification)
            .then(() => {
                returnObject.data = {
                    idFollow: returnObject.data.idFollow,
                    idRequestStatus: returnObject.data.idRequestStatus
                }

                return res.status(201).json(returnObject)
            })
            .catch((err) => {
                console.log(err)
                const errorCallback = (retObject) => {
                    return res.status(500).json({ status: -11, error: "Internal error" })
                }

                execProcedure('usp_followDelete', { id: returnObject.data.idFollow }, req.idUser, errorCallback)
            })
    }

    execProcedure('usp_followCreate', req.body, req.idUser, callback)
});


router.put('/', [
    check('idNotification', 'Campo obligatorio').not().isEmpty(),
    check('idRequestStatus', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        Notification.deleteNotification(req.body.idNotification, req.idUser)
            .then(() => {
                return res.status(200).json(returnObject)
            })
            .catch((err) => {
                console.log(err)
                return res.status(500).json({ status: -11, error: "Internal error" })
            })
    }

    execProcedure('usp_followUpdate', req.body, req.idUser, callback)
});


router.delete('/:id', [
], async (req, res) => {
    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(201).json(returnObject)
    }

    execProcedure('usp_followDelete', req.params, req.idUser, callback)
});

router.get('/followers', async (req, res) => {
    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if (returnObject.data && returnObject.data.followers) {
            returnObject.data.followers = JSON.parse(returnObject.data.followers)
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_followersListGet', req.query, req.idUser, callback)
});

router.get('/follows', async (req, res) => {
    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if (returnObject.data && returnObject.data.follows) {
            returnObject.data.follows = JSON.parse(returnObject.data.follows)
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_followsListGet', req.query, -2, callback)
});


module.exports = router;