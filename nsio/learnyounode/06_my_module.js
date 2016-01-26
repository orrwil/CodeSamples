function my_ls(path, fileExt, callback) {
    var fs = require('fs');
    
    function fileType(value) {
        if (value.substr(value.length-(fileExt.length+1)) === fileExt){
            return value;
        }
    }
    
fs.readdir(path, function(err, list){
        if (err) return callback(err);
        var results = list.filter(fileType);
        for (var i=0; i<results.length; i++){
            return callback(results[i]);
        }
    });
    return callback();
}

module.exports = my_ls;