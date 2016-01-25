var fs = require('fs');

var path = process.argv[2];
var fileExt = process.argv[3];

function fileType(value) {
    if (value.substr(value.length-(fileExt.length+1)) === "."+fileExt){
        return value;
    }
}

fs.readdir(path, function(err, list){
    if (err) throw err;
    //console.log("FULL LIST:" + list);
    var results = list.filter(fileType);
    for (var i=0; i<results.length; i++){
        console.log(results[i]);
    }
    
});