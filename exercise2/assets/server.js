const express = require('express');
const app = express();
app.get("/", function(req, res) {
    res.send("I'm worging!");
});
app.get("/liveness", function(req, res) {
    res.send("");
});
app.get("/readness", function(req, res) {
    res.send("");
});