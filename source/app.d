import std.stdio;
import std.socket;

void main()
{
	writeln("This might be an irc server at some point");
	TcpSocket serverSocket = new TcpSocket();
	serverSocket.bind(getAddress("0.0.0.0", 6667)[0]);
	serverSocket.listen(1);
	serverSocket.accept();
	char[50] received;
	while(true) {
		serverSocket.receive(received);
		writeln(received);
	}
}
