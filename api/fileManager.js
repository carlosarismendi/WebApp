const multer = require('multer');
const path = require('path')
const moment = require('moment')

const isImage = (req, res, next) => {
    if (!req.file) {
        next()
        return
    }

    const isImage = (req.file.mimetype.indexOf('image') >= 0)
    if (!isImage) {
        return res.status(415).json({ status: -18, error: "Invalid file type" });
    }

    next()
}

// ########### IMAGE COMPRESSION ###########

const imagemin = require('imagemin')
const imageminWebp = require('imagemin-webp');

const compressImage = async (file, res) => {
    const fileAux = await imagemin.buffer(file.buffer, {
        plugins: [
            imageminWebp({ quality: 60 })
        ]
    })

    file.buffer = fileAux
    file.size = fileAux.length
}

// ########### BEGIN AZURE STORAGE ############
const { BlobServiceClient } = require('@azure/storage-blob');

const AZURE_STORAGE_URL = process.env.AZURE_STORAGE_URL
const AZURE_STORAGE_CONNECTION_STRING = process.env.AZURE_STORAGE_CONNECTION_STRING

const azureMulter = multer({ storage: multer.memoryStorage() })

const uploadAzure = async (file, res, container, idUser) => {
    const blobServiceClient = BlobServiceClient.fromConnectionString(AZURE_STORAGE_CONNECTION_STRING);
    const containerClient = blobServiceClient.getContainerClient(container);

    const blobName = `${idUser}${moment().format('DDSSYYYYmmHHMMmmssSSS')}${path.extname(file.originalname)}`

    file.originalname = `${AZURE_STORAGE_URL}/${container}/${blobName}`

    const blockBlobClient = containerClient.getBlockBlobClient(blobName);
    await blockBlobClient.upload(file.buffer, file.buffer.length)
        .then(res => {})
        .catch(e => {
            console.log(e)
            return res.status(500).json({ status: -11, error: "Internal error" })
        });
}

const deleteAzure = async (fileName, container) => {
    const blobServiceClient = BlobServiceClient.fromConnectionString(AZURE_STORAGE_CONNECTION_STRING);
    const containerClient = blobServiceClient.getContainerClient(container);

    const blobName = path.basename(fileName)

    const blockBlobClient = containerClient.getBlockBlobClient(blobName)
    if (blockBlobClient.exists()) {
        blockBlobClient.delete()
    }
}

// ########### END AZURE STORAGE ############

const uploadRemote = async (req, res, next, route) => {
    if (!req.file) {
        next()
        return
    }

    await compressImage(req.file, res)
    await uploadAzure(req.file, res, route, req.idUser)

    next()
}

const deleteRemote = async (fileName, folder) => {
    if(!fileName || !folder) return
    deleteAzure(fileName, folder)
}

module.exports = {
    upload: azureMulter,
    uploadRemote: uploadRemote,
    deleteRemote: deleteRemote,
    isImage: isImage
}