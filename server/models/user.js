const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    name:{
        type:String,
        required:true,

    },
    email:{
        type:String,
        required: true,
    },
    profilePic:{
        type:String,
        required: true,
    },
});

// user data base
const User = mongoose.model("User",userSchema);
module.exports=User;