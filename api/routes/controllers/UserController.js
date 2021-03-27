const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');
const fileManager = require('../../fileManager')

const imageStorageContainer = 'images'

router.get('/', async (req, res) => {
    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if (returnObject.data && returnObject.data.users) {
            returnObject.data.users = JSON.parse(returnObject.data.users)
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_userListGet', req.query, req.idUser, callback)
});

router.get('/:id', async (req, res) => {
    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if(returnObject.data && returnObject.data.errorCode !== null) {
            returnObject.status = returnObject.data.errorCode
            returnObject.error = returnObject.data.errorDescription

            returnObject.data = {
                idUser: returnObject.data.idUser,
                nickname: returnObject.data.nickname,
                name: returnObject.data.name,
                profileImage: returnObject.data.profileImage,
                totalFollows: returnObject.data.totalFollows,
                totalFollowers: returnObject.data.totalFollowers,
                idFollow: returnObject.data.idFollow,
                idRequestStatus: returnObject.data.idRequestStatus
            }
        } else {
            delete returnObject.data.errorCode
            delete returnObject.data.errorDescription
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_userGet', req.params, req.idUser, callback)
});

router.put('/', [
    check('nickname', 'Campo obligatorio').not().isEmpty(),
    check('name', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -4) {
            return res.status(409).json(returnObject)
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(201).json(returnObject)
    }

    execProcedure('usp_userUpdate', req.body, req.idUser, callback)
});

router.put('/firebase-token', [
], async (req, res) => {
    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(201).json(returnObject)
    }

    execProcedure('usp_userUpdateFirebaseToken', req.body, req.idUser, callback)
});

router.put('/profile-image', [
],  fileManager.upload.single('profileImage'), fileManager.isImage, (req, res, next) => {
    fileManager.uploadRemote(req, res, next, imageStorageContainer)
}, async (req, res) => {
    const callback  = function(returnObject){
        if(!returnObject){
            if(req.file) fileManager.deleteRemote(req.file.originalname, imageStorageContainer) // Elimina de Azure la imagen nueva, si la hubiera
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if (returnObject.data) {
            fileManager.deleteRemote(returnObject.data.oldProfileImage, imageStorageContainer) // Elimina de Azure la imagen vieja, si la hubiera
            delete returnObject.data.oldProfileImage
        }

        return res.status(201).json(returnObject);
    };

    let params = {
        profileImage: req.file ? req.file.originalname : null
    }

    execProcedure('usp_userProfileImageUpdate', params, req.idUser, callback);
});

router.delete('/', async (req, res) => {
    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if (returnObject.data) {
            fileManager.deleteRemote(returnObject.data.oldProfileImage, imageStorageContainer) // Elimina de Azure la imagen vieja, si la hubiera
        }

        returnObject.data = null
        return res.status(201).json(returnObject)
    }

    execProcedure('usp_userDelete', { }, req.idUser, callback)
});

module.exports = router;