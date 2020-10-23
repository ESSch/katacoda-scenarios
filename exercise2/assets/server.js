const express = require('express');
const app = express();
app.get("/", function(req, res) {
    // if [ $(( ( RANDOM % 10 ) + 1 )) == 1 ]; then sleep 10 > front.html;
    // if [ $(( ( RANDOM % 2 ) + 1 )) == 1 ]; then gen.sh > front.html; fi; # эмуляция неработоспособности
    res.download(front.html);
});
app.get("/liveness", function(req, res) {
    let status = 200;
    res.status(status);
    res.send("Ok");
});
app.get("/readness", function(req, res) {
    res.status(200);
    res.send("Ok");
});