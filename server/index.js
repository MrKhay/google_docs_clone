const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const Document = require("./models/document");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const http = require("http");
const PORT = process.env.PORT | 3001;
const app = express();


var server = http.createServer(app);
var io = require("socket.io")(server);


// for cross platform application
app.use(cors());
app.use(express.json()); 
app.use(authRouter);
app.use(documentRouter)

// mogo credentials
const DB = "mongodb+srv://Khay:GO083cuWwTO8vd7w@cluster0.qbnpndo.mongodb.net/?retryWrites=true&w=majority"

// localhost:3001/api/signup

mongoose.connect(DB).then(()=>{

console.log("Connected To MongoDB")

}).catch((e)=>{

    console.log("Error: ",e);

});

io.on('connection',(socket)=>{


    socket.on('join',(documentId)=>{

        console.log('Joined room', documentId);

        socket.join(documentId);
       
    });
   
    socket.on('livingRoom',(room)=>{

        console.log('living room', room);
        socket.leave(room);
       
    });

    socket.on('typing',(data)=>{
        socket.broadcast.to(data.room).emit('changes',data);
    });
 
    socket.on('save',(data)=>{
      saveData(data);
    
    });


    socket.on('updatingtitle',(data)=>{
        socket.broadcast.to(data.room).emit('updatedTitle',data);
    });
    
});

// io.to sends data to everyone including the sender
// socket.broadcast sends the data to everyone expect the sender

const saveData = async(data)=>{
   await Document.findByIdAndUpdate(data.room,{ content:data.delta});

}


server.listen(PORT,"0.0.0.0",()=>{
    console.log(`Conntected at port: ${PORT.toString()}`);
});