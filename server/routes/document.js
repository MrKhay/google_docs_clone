const express = require("express");
const Document = require("../models/document");
const jwt = require("jsonwebtoken");
const auth = require("../middlewares/auth");

const documentRouter = express.Router();


// create new document
documentRouter.post("/doc/create", auth , async (req,res)=>{

  try {

    const {createdAt} = req.body;
   let document = new Document({
    uid:req.user,
    title:'Utitled Document',
    createdAt,
   });
  
   document = await document.save();
  
   res.json(document);
  
  } catch (e) {
    console.log('Called');
    res.status(500).json({error:e.message})
  }

});


// set document title
documentRouter.post("/doc/title", auth , async (req,res)=>{

  try {
    const { id , title } = req.body;

    const document = await Document.findByIdAndUpdate(id,{ title });
  
   res.json(document);
  
  } catch (e) {
    console.log('Called');
    res.status(500).json({error:e.message})
  }

});


// get all user documents
documentRouter.get('/docs/me',auth , async (req,res)=>{

try {

let documents = await Document.find({uid:req.user});

res.json(documents);
  console.table(documents);
} catch (e) {
  res.status(500).json({error:e.message});
}


});

// get a particular document by its id
documentRouter.get('/doc/:id',auth , async (req,res)=>{

try {

const documents = await Document.findByIdAndUpdate(req.params.id);
res.json(documents);

} catch (e) {
  res.status(500).json({error:e.message});
}


});






module.exports=documentRouter;