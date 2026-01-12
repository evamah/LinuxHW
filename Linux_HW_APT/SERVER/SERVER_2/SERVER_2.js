const http = require("http");
const { exec } = require("child_process");

const PORT = 4000;

const LINUX_CMD = "hostname && uptime && lsb_release -d";

const server = http.createServer((req, res) => {

    const timestamp = new Date().toISOString();

    exec(LINUX_CMD, (error, stdout, stderr) => {

        const response = {
            stdout: stdout.trim(),
            stderr: stderr.trim(),
            timestamp: timestamp
        };

        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(response, null, 2));
    });

});

server.listen(PORT, () => {
    console.log(`SERVER_2 listening on port ${PORT}`);
});
