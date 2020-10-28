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
    res.setHeader("Content-Type", "text/html");
    let status = 200; 
    switch (req.url) {
        case "/":
            console.log({front: status});
            // const data = fs.readFileSync("front.html")
            res.writeHead(status);
            res.end("Hello!");
            break
        case "/liveness":
            console.log({liveness: status});
            res.writeHead(status);
            res.end(`${status}`);
            break
        case "/readiness":
            console.log({readiness: status});
            res.writeHead(status);
            res.end(`${status}`);
            break
    }
};
const server = http.createServer(requestListener);
const port = 9000;
const host = 'localhost'
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});