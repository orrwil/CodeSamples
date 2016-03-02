var dir = process.argv[2];
var filter = process.argv[3];
var mymodule = require('./06_program5');

mymodule (dir,filter, function (err, data) {
    if (err) {
        console.log("Wild error appeared!");
    }
    else {
        for (var x in data){
          console.log(data[x]);
        }
    }
})