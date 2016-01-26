var mymodule = require('./06_my_module.js');

var p = process.argv[2];
var f = process.argv[3];

mymodule (p, f, function(err, list){
	if (err) throw err;
	console.log(list);
});
	
