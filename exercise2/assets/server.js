// const express = require('express');
// const app = express();
// app.get("/", function(req, res) {
//     // if [ $(( ( RANDOM % 10 ) + 1 )) == 1 ]; then sleep 10; echo besy > status.txt;
//     // if [ $(( ( RANDOM % 2 ) + 1 )) == 1 ]; then gen.sh > front.html; fi; # эмуляция неработоспособности
//     res.download(front.html);
// });
// // app.get("/liveness", function(req, res) {
// //     const status = 200;
// //     res.status(status);
// //     res.send("Ok");
// // });
// // app.get("/readiness", function(req, res) {
// //     const status = 200;
// //     res.status(status);
// //     res.send("Ok");
// // });
// app.listen(9000, function () {
//     console.log("Start");
// });

const http = require("http");
const requestListener = function (req, res) {
    res.setHeader("Content-Type", "application/json");
    switch (req.url) {
        case "/":
            res.setHeader("Content-Type", "text/html");
            res.writeHead(200);
            res.end("Hello!");
        case "/liveness":
            const status = 200;
            res.writeHead(status);
            res.end("Ok");
            break
        case "/readiness":
            const status = 200;
            res.writeHead(status);
            break
    }
};
const server = http.createServer(requestListener);
server.listen(9000, 'localhost', () => {
    console.log(`Server is running on http://${host}:${port}`);
});