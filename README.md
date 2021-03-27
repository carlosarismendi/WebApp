# WebApp
Socialmedia web app developed in [NodeJS](https://nodejs.org/es/) using Express connected to an Azure SQL Database with push notifications created by [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging). The user interface is developed in VueJS. The authentication is performed using JWT-Tokens.

This repository is organized in 3 directories:
<ul>
  <li>`api`: [NodeJS](https://nodejs.org/es/) project in charge of managing user request whether sending information to the database and/or retrieving data from it. It also performs some mild validations and prepares the data received from the database to send it properly formatted to the user. In some particular cases, push notifications are generated asynchronously using [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) .</li>

  <li>`db`: divided in 2 folders: `scripts`, which are the necessary scripts to create the database structure and tables. They also show the evolution suffered by the database (new fields, new tables and new master registers created on the run). On the other folder, `storedProcedures` contains all the stored procedures that are required for validating and creating new registers, loading and filtering, etc. The database is [Microsoft Azure SQL](https://azure.microsoft.com/en-us/free/sql-database/search/?&ef_id=CjwKCAjwr_uCBhAFEiwAX8YJgbfkAms2nTCO30WnYsiW0zP34qbFGA--CM2g4EAKt-TZtPptJ3j3CBoC9pcQAvD_BwE:G:s&OCID=AID2100112_SEM_CjwKCAjwr_uCBhAFEiwAX8YJgbfkAms2nTCO30WnYsiW0zP34qbFGA--CM2g4EAKt-TZtPptJ3j3CBoC9pcQAvD_BwE:G:s&dclid=CjgKEAjwr_uCBhCn58v0-sW46CQSJACewXbfCmEAwJmWbs-BCrijoXQE1skcVGoNIAMix00ppmi8pPD_BwE)</li>

  <li>`ui`: user interface project developed in [VueJS](https://vuejs.org/) using [BootstrapVue](https://bootstrap-vue.org/)</li>
</ul>

## API (NodeJS, Express)
.env and /keys/keys.json (firebase credentials for notification purposes) files must be configured. Templates are provided indicating the variables that must be set.
Once configured we can run the project inside the root api folder:
 ```bash
 npm install
 npm run dev
```

## Database (Azure SQL)
All the scripts must be executed one by one in the order specified in their naming (from 1 to n) and then, run one by one the stored procedures.

## UI (VueJS)
.env, firebase-messagin-sw.js and /public/firebase-messaging-sw.js (firebase credentials) files must be configured. Templates are provided indicating the variables that must be set.
Once configured we can run the project inside the root api folder:
 ```bash
 npm install
 npm run serve
```