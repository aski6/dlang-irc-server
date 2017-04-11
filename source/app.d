import std.stdio;
import std.socket;
import config;

void main() {
	writeln("This might be an irc server at some point");
	TcpSocket connectionListener = new TcpSocket();
	connectionListener.bind(new InternetAddress(ADDR, PORT));
	connectionListener.listen(1);
	char[512] buffer;
	while(true) {
		try {
			Socket server = connectionListener.accept();
			while(server.isAlive()) {
				auto num = server.receive(buffer);
				if(num == 0) { //check that some data has actually been received, if not, our nc socket(used for testing receiving of data from socket) is not active, so start wait for another connection.
					break;
				}
				writeln(num);
				write(buffer[0.. num]);
			}
		} catch {
			writeln("there was an error :(");
		}
	}
}
