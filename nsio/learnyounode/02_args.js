var count=0;
for(x=2;x<process.argv.length;x++){
	count+=Number(process.argv[x]);
	//console.log("x = "+x+"/n arg[x] = "+process.argv[x]);
}
console.log(count);
