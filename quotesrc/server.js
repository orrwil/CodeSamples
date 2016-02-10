var express = require('express'),
    quote = require('./routes/quotes');

var app = express();

app.configure(function () {
    app.use(express.logger('dev'));     /* 'default', 'short', 'tiny', 'dev' */
    app.use(express.bodyParser());
});

app.get('/quotes', quote.findAll);
app.get('/quotes/:id', quote.findById);
app.post('/quotes', quote.addQuote);
app.put('/quotes/:id', quote.updateQuote);
app.delete('/quotes/:id', quote.deleteQuote);

app.listen(7868);
console.log('Listening on port 7868...');