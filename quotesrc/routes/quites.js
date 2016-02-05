var express = require('express');

var app = express();

app.get('/quotes', function(req, res) {
    res.send([{name:'quote1'}, {name:'quote2'}]);
});
app.get('/quotes/:id', function(req, res) {
    res.send({id:req.params.id, name: "The Name", description: "description"});
});

app.listen(7868);
console.log('Listening on port 7868...');
