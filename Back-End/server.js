const WebSocket = require('ws');
const server = new WebSocket.Server({ port: 8080 });

const clients = new Set();

server.on('connection', socket => {
  console.log('🔌 Client connected');
  clients.add(socket);

  socket.send(JSON.stringify({ system: 'მოგესალმები ჩატში!' }));

  socket.on('message', msg => {
    console.log('📩 Client says:', msg.toString());

    // გააგზავნე ეს მესიჯი ყველა სხვა კლიენტზე
    for (const client of clients) {
      if (client !== socket && client.readyState === WebSocket.OPEN) {
        client.send(msg.toString());
      }
    }
  });

  socket.on('close', () => {
    clients.delete(socket);
    console.log('❌ Client disconnected');
  });
});