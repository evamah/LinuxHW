const http = require('http');

const server = http.createServer((req, res) => {
    const response = {
        message: "Hello from Linux server",
        timestamp: new Date().toISOString(),
        random: Math.floor(Math.random() * 100) + 1
    };

    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(response));
});

server.listen(3000, () => {
    console.log("Server running on port 3000");
});
