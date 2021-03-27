const router = require('express').Router();
const bcryp = require('bcryptjs');
const { execProcedure } = require('../../dataBase');
const { check, validationResult } = require('express-validator');
const fileManager = require('../../fileManager')

const imageStorageContainer = 'images'

router.get('/user', async (req, res) => {
    if (!req.query.id) {
        return res.status(422).json({ error: "Missing necessary data" });
    }

    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -2) {
            return res.status(422).json(returnObject)
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if(returnObject.status === -17) {
            return res.status(200).json(returnObject)
        }

        if (returnObject.data && returnObject.data.posts) {
            returnObject.data.posts = JSON.parse(returnObject.data.posts)
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_postUserGet', req.query, req.idUser, callback)
});


router.get('/all', async (req, res) => {
    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if (returnObject.data && returnObject.data.posts) {
            returnObject.data.posts = JSON.parse(returnObject.data.posts)
        }

        return res.status(200).json(returnObject)
    }

    execProcedure('usp_postAllGet', req.query, req.idUser, callback)
});

router.post('/',
    fileManager.upload.single('image'), fileManager.isImage, (req, res, next) => {
    fileManager.uploadRemote(req, res, next, imageStorageContainer)
}, async (req, res) => {
    if (!req.file) {
        return res.status(422).json({ error: "Missing necessary data" });
    }

    const callback  = function(returnObject){
        if(!returnObject){
            if(req.file) fileManager.deleteRemote(req.file.originalname, imageStorageContainer) // Elimina de Azure la imagen nueva, si la hubiera
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -2) {
            return res.status(422).json(returnObject)
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        if (returnObject.data) {
            fileManager.deleteRemote(returnObject.data.oldProfileImage, imageStorageContainer) // Elimina de Azure la imagen vieja, si la hubiera
            delete returnObject.data.oldProfileImage
        }

        return res.status(201).json(returnObject);
    };

    let params = {
        image: req.file.originalname,
        description: req.body.description
    }

    execProcedure('usp_postCreate', params, req.idUser, callback);
});


router.put('/', [
    check('idPost', 'Campo obligatorio').not().isEmpty()
], async (req, res) => {
    const errors = validationResult(req);

    if(!errors.isEmpty()){
        return res.status(422).json({ status: -2, error: "Missing necessary data" });
    }

    const callback = (returnObject) => {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -2) {
            return res.status(422).json(returnObject)
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(201).json(returnObject)
    }

    execProcedure('usp_postUpdate', req.body, req.idUser, callback)
});


router.delete('/:id', async (req, res) => {
    const callback = (returnObject)=> {
        if(!returnObject) {
            return res.status(500).json({ status: -11, error: "Internal error" })
        }

        if(returnObject.status === -2) {
            return res.status(422).json(returnObject)
        }

        if(returnObject.status === -9) {
            return res.status(404).json(returnObject)
        }

        return res.status(201).json(returnObject)
    }

    execProcedure('usp_postDelete', req.params, req.idUser, callback)
});



module.exports = router;
