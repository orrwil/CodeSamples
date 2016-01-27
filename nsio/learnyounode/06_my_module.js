function my_ls(path, fileExt, callback) {
    var fs = require('fs');
    
    function fileType(value) {
        if (value.substr(value.length-fileExt.length) === fileExt){
            return blcavalue;
        }
    }
   
    fs.readdir(path, function(err, list){
        if (err) {
            return callback(err);
        }
        else {
            var results = list.filter(fileType);
            // for (var i=0; i<results.length; i++){
            return callback(results);
        }
    });
};

my_ls("./", "js", function(err,list) {
    if (err) return err;
    for (var i=0; i<list.length; i++){
        console.log(list[i]);
    }
});
//module.exports = my_ls;