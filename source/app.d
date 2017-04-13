import std.stdio;
import std.socket;
import config;

void main() {
	writeln("This might be an irc server at some point");
	auto listener = new TcpSocket();
	listener.blocking = false;
	listener.bind(new InternetAddress(ADDR, PORT));
	listener.listen(1);
	writeln("Listening for incoming connections on address %s, port %d.", ADDR, PORT);

	auto socketSet = new SocketSet(MAX_CONNECTIONS + 1); // +1 leaves room for the listener socket.
	Socket[] connections;

	while (true) {
		socketSet.add(listener);

		foreach (socket; connections) {
			socketSet.add(socket);
		}

		Socket.select(socketSet, null, null);

		for (int i = 0; i < connections.length; i++) { //for each socket
			if(socketSet.isSet(connections[i])) { //if socket accessed by loop has changed state
				char[512] buffer; //irc has a maximum message length of 512 chars, including CR-LF ending (2 chars)
									
			}
		}
	}
	/*
	while(true) {
		try {
			Socket server = listener.accept();
			while(server.isAlive()) {
				auto num = server.receive(buffer);
				if(num == 0) { //check that some data has actually been received, if not, our nc socket(used for testing receiving of data from socket) is not active, so start wait for another connection.
					break;
				}
				//writeln(num);
				write(buffer[0.. num]);
			}
		} catch {
			writeln("there was an error :(");
		}
	}
	*/
}
