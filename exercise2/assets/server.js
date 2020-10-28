//     // if [ $(( ( RANDOM % 10 ) + 1 )) == 1 ]; then sleep 10; echo besy > status.txt;
//     // if [ $(( ( RANDOM % 2 ) + 1 )) == 1 ]; then gen.sh > front.html; fi; # эмуляция неработоспособности
const fs   = require("fs");
const http = require("http");
const requestListener = function (req, res) {
    res.setHeader("Content-Type", "text/html");
    try {
        let status = 200; 
        switch (req.url) {
            case "/":
                console.log({front: status});
                const data = fs.readFileSync("front.html");
                res.writeHead(status);
                res.end(data);
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
    } catch (err) {
        console.log({err});
        res.writeHead(status);
        res.end(`Приложение не работает: ${err}`);
    }
};
const server = http.createServer(requestListener);
const port = 9000;
const host = "0.0.0.0"
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});