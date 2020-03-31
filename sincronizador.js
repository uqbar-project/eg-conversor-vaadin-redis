var redis = require('redis');

var client = redis.createClient(); 

client.on('connect', function() {
    console.log('connected');
    client.lpop("dolar", redis.print);
    client.rpush("dolar","62.36", redis.print);
    client.set("euro","69.48", redis.print);
    client.set("real","13.6", redis.print);
    client.quit();
    console.log("valores actualizados..");
});
client.on("error", function (err) {
    console.log("Error " + err);
});

