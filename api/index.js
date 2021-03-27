// Import libraries.
const express = require('express');
const bodyParser = require('body-parser');
const apiRouter = require('./routes/api');
const cors = require('cors');

// Config application.
const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors({ origin: process.env.WEB_URL }));

app.use('/api', apiRouter);

//Config server.
app.listen(process.env.PORT, () =>{
    console.log("Servidor iniciado.");
});