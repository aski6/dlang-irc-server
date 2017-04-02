import std.stdio;
import std.socket;

void main() {
	writeln("This might be an irc server at some point");
	string addr = "0.0.0.0";
	ushort port = 6667;
	TcpSocket connectionListener = new TcpSocket();
	connectionListener.bind(new InternetAddress(addr, port));
	connectionListener.listen(1);
	char[512] buffer;
	while(true) {
		try {
			Socket server = connectionListener.accept();
				auto num = server.receive(buffer);
			writeln(buffer[0.. num]);
		} catch {
			writeln("there was an error :(");
		}
	}
}
