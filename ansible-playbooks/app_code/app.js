// app.js

const http = require('http'); // Import the built-in Node.js http module
const port = process.env.PORT || 8080; // Use environment variable PORT or default to 8080

// Create an HTTP server
const server = http.createServer((req, res) => {
  // Set the response HTTP header with HTTP status and Content-Type
  res.statusCode = 200; // OK
  res.setHeader('Content-Type', 'text/plain'); // Indicate plain text content

  // Send the response body "Hello World"
  res.end('Hello from our Node.js Web App deployed with HCP Terraform, Ansible, and IBM Cloud CD!\n');
});

// The server listens on specified port and IP address (0.0.0.0 for all available interfaces)
server.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}/`);
});

console.log('Node.js app is running...');
