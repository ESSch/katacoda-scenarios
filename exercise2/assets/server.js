const express = require('express');
const app = express();
app.get("/", function(req, res) {
    // sleep 5
    // if [ $(( ( RANDOM % 2 ) + 1 )) == 1 ]; then echo 'Hello' > front.html; fi;
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