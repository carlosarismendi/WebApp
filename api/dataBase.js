const Sql = require('mssql');

const pool = new Sql.ConnectionPool({
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    server: process.env.DB_HOST,
    database: process.env.DB_NAME
})

const execProcedure = (spName, spParams, idUser, callback) => {
    pool.connect(err =>{
        let returnObject = {
            status: null,
            data: null,
            error: null
        };

        if(!!err){
            console.log(err);
            callback();
        }else{
            const request = new Sql.Request(pool);
            request.input('p_json', Sql.NVarChar(Sql.MAX), JSON.stringify(spParams));
            request.input('p_idUser', Sql.Int, idUser);

            request.execute(spName, (err, result) => {
                if(!!err){
                    console.log(err);
                    callback();
                }else{
                    returnObject.status = result.returnValue

                    if (result.recordset) {
                        if (returnObject.status >= 0) {  // No errors
                            if (result.recordset.length === 1) {
                                returnObject.data = result.recordset[0];
                            } else if (result.recordset.length > 1) {
                                returnObject.data = result.recordset;
                            }
                        } else { // There's one error
                            returnObject.error = result.recordset[0].description;
                        }
                    }

                    callback(returnObject);
                }
            });
        }
    });
};

module.exports = {
    execProcedure: execProcedure
};