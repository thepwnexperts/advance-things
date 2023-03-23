//import
const spdy = require("spdy")
const express = require("express")
const fs = require("fs")
const {promisify} = require("util")
var compression = require('compression');
const dotenv = require('dotenv');
dotenv.config();
const cors = require('cors');
const db = require ('mongoose');
const helmet = require("helmet");
//test
//const { xss } = require('express-xss-sanitizer');
//app.use(xss());


//ex
const readFile = promisify(fs.readFile)
const app = express()

//mid
app.use(helmet());
app.use(express.json());
app.use(cors());
app.use(compression());


//paths
const verifypath=require('./routes/query');
//const test=require('./routes/query');

//routes
//local
app.use("/",verifypath);
//app.use("/test",test);


//db
try{
    db.connect(process.env.dburi)
  .then(() => console.log('DB Connection Successful'));
}
catch(e)
{
    console.log(e)
};


const port =3045;

spdy.createServer(
  {
    key: fs.readFileSync("/etc/letsencrypt/live/api.ibharat.org/privkey.pem"),
    cert: fs.readFileSync("/etc/letsencrypt/live/api.ibharat.org/fullchain.pem")
  },
  app
).listen(port, (err) => {
  if(err){
    throw new Error(err)
  }
  console.log("Listening on port " + port )
})
