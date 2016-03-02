var fs = require('fs');
var path = require('path');

module.exports = function(dir,filter,callback){
fs.readdir(dir,function(err, data){
  final=[];
  for (x in data){
    if(path.extname(data[x])=="."+filter){
      final.push(data[x]);
     }
    }
  return callback(null,final);
  });
}