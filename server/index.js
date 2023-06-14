const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");


const PORT = process.env.PORT | 3001;
const app = express();

// for cross platform application
app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter)

// mogo credentials
const DB = "mongodb+srv://Khay:GO083cuWwTO8vd7w@cluster0.qbnpndo.mongodb.net/?retryWrites=true&w=majority"

// localhost:3001/api/signup

mongoose.connect(DB).then(()=>{

console.log("Connection To MongoDB")

}).catch((e)=>{

    console.log("Error: ",e);

});

app.listen(PORT,"0.0.0.0",()=>{
    console.log(`Conntected at port: ${PORT.toString()}`);
});