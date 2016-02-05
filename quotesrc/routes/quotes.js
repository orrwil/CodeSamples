var mongo = require('mongodb');

var Server = mongo.Server,
    Db = mongo.Db,
    BSON = mongo.BSONPure;

var server = new Server('localhost', 27017, {auto_reconnect: true});
var db = new Db('quotedb', server);

db.open(function(err, db) {
    if(!err) {
        console.log("Connected to 'quotedb' database");
        db.collection('quotes', {strict:true}, function(err, collection) {
            if (err) {
                console.log("The 'quotes' collection doesn't exist. Creating it with sample data...");
                populateDB();
            }
        });
    }
});

exports.findById = function(req, res) {
    var id = req.params.id;
    console.log('Retrieving quote: ' + id);
    db.collection('quotes', function(err, collection) {
        collection.findOne({'_id':new BSON.ObjectID(id)}, function(err, item) {
            res.send(item);
        });
    });
};

exports.findAll = function(req, res) {
    db.collection('quotes', function(err, collection) {
        collection.find().toArray(function(err, items) {
            res.send(items);
        });
    });
};

exports.addQuote = function(req, res) {
    var quote = req.body;
    console.log('Adding quote: ' + JSON.stringify(quote));
    db.collection('quotes', function(err, collection) {
        collection.insert(quote, {safe:true}, function(err, result) {
            if (err) {
                res.send({'error':'An error has occurred'});
            } else {
                console.log('Success: ' + JSON.stringify(result[0]));
                res.send(result[0]);
            }
        });
    });
}

exports.updateQuote = function(req, res) {
    var id = req.params.id;
    var quote = req.body;
    console.log('Updating quote: ' + id);
    console.log(JSON.stringify(quote));
    db.collection('quotes', function(err, collection) {
        collection.update({'_id':new BSON.ObjectID(id)}, quote, {safe:true}, function(err, result) {
            if (err) {
                console.log('Error updating quote: ' + err);
                res.send({'error':'An error has occurred'});
            } else {
                console.log('' + result + ' document(s) updated');
                res.send(quote);
            }
        });
    });
}

exports.deleteQuote = function(req, res) {
    var id = req.params.id;
    console.log('Deleting quote: ' + id);
    db.collection('quotes', function(err, collection) {
        collection.remove({'_id':new BSON.ObjectID(id)}, {safe:true}, function(err, result) {
            if (err) {
                res.send({'error':'An error has occurred - ' + err});
            } else {
                console.log('' + result + ' document(s) deleted');
                res.send(req.body);
            }
        });
    });
}

/*--------------------------------------------------------------------------------------------------------------------*/
// Populate database with sample data -- Only used once: the first time the application is started.
// You'd typically not find this code in a real-life app, since the database would already exist.
var populateDB = function() {

    var quotes = [
    {
        quote: "A bird in the hand, is worth two in the bush",
        year: "2016",
        person: "Anon"
    },
    {
        quote: "A day without a laugh is a wasted day.",
        year: "1906",
        person: "Charles Chaplin"        


    }];

    db.collection('quotes', function(err, collection) {
        collection.insert(quotes, {safe:true}, function(err, result) {});
    });

};