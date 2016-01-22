var fs = require('fs');
var fileStr = fs.readFileSync(process.argv[2]).toString();
//console.log(fs.readFileSync(process.argv[2]).toString().split('\n').length-1);
console.log(fileStr.split('\n').length-1);