import std.stdio;
import std.socket;
import std.algorithm.mutation;
import std.conv;
import std.array;
import std.format;
import std.string;

import config;
import client;
import channel;

void main() {
	writefln("This might be an irc server at some point");

	//Receive data from sockets and setup incoming connections.
	auto listener = new TcpSocket(); //Create a socket to listen for incoming connection requests.
	assert(listener.isAlive); //listener must have the isAlive property true.
	listener.blocking = false; //Make listener non-blocking since the program is not multi-threaded, and we want to do things while waiting for sockets to do stuff.
	listener.bind(new InternetAddress(ADDR, PORT));
	listener.listen(1);

	//start the program loop checking sockets.
	writefln("Listening for incoming connections on address %s, port %d.\n", ADDR, PORT);

	auto socketSet = new SocketSet(MAX_CONNECTIONS + 1); //create a socketset with enough slots for the mac number of connections. +1 leaves room for the listener socket. The socketset allows us to keep track of which sockets have updates that need processing
	while (true) {

		socketSet.add(listener);//Add the listener socket to the socket set so that we can process any updates from it.

		foreach (client; clients) { //process message queues
			//go through each channel the client is part of then copy the channel message queue to the client
			foreach (channel; client.channels) {
				foreach (message; channels[channel].queue) {
					client.queue ~= message;
				}
			}
			//then send all messages in the client's message queue to the client.
			foreach (message; client.queue) {
				client.conn.send(message);
			}
			//clear the client's message queue.
			client.queue = [];
			socketSet.add(client.conn); //add all connections to socketSet to be checked for status chages.
		}

		//process updates from our connection's sockets.
		Socket.select(socketSet, null, null);  //get list of sockets that have changed status.
		for (size_t i = 0; i < clients.length; i++) {
			if (socketSet.isSet(clients[i].conn)) { //if socket being checked has a status update.
				char[512] buffer; //irc has a maximum message length of 512 chars, including CR-LF ending (2 chars).
				auto recLen = clients[i].conn.receive(buffer); //recLen stores the length of the data received into the buffer.
				if (recLen == Socket.ERROR) {
					writefln("There was an error receiving from the socket. :(");
				} else if (recLen != 0) {
					processMessage(buffer, recLen, i);
				} else {
					try {
						//try to state address of socket closing, may fail if connections[i] was closed due to an error.
						writefln("Connection from %s closed.", clients[i].conn.remoteAddress().toString());
					} catch (SocketException) {
						writefln("Connection closed.");
					}
					clients[i].conn.close();
					clients = clients.remove(i);
					i--;
				}
			}
		}

		if (socketSet.isSet(listener)) { //if there was a connection request.
			Socket sn = null;
			scope (failure) { //if client creation fails, run this.
				writefln("Error accepting connection");
				if (sn) {
					sn.close();
				}
			}
			sn = listener.accept();
			assert(sn.isAlive);
			assert(listener.isAlive);
			if (clients.length < MAX_CONNECTIONS) {
				writefln("Connection from %s established.", sn.remoteAddress().toString());
				clients ~= new Client(sn, ("Guest"~to!string(clients.length)));
			} else {
				writefln("Rejected connection from %s: max connections already reached.", sn.remoteAddress().toString());
				sn.close();
				assert(!sn.isAlive);
				assert(listener.isAlive);
			}
		}
		socketSet.reset();
	}
}

void processMessage(char[512] buffer, long recLen, size_t clientIndex) {
	writefln("Received %d bytes from %s: %s", recLen, clients[clientIndex].conn.remoteAddress().toString(), buffer[0.. recLen]);
	if (buffer[recLen-1] == '\n') {
		string[] messages = split(to!string(buffer[0.. recLen]), '\n'); //Split the received data into all the seperate message, messages will end with \n

		for (int i=0; i < messages.length; i++) { //execute this code for each message.
			messages[i] = removechars(messages[i], "\r"); //remove any \r characters from the message cuz compatability is a thing.

			if (messages[i].length > 0) { //If there is any content left in the messages after removing control characters.
			
				string[] message = split(messages[i], " "); //Split the message into it's individual components, sperated by spaces.
				bool hasPrefix = false;
				string prefix;
			
				if (buffer[0] == ':') { //If the message has a prefix, set the prefix status to true and set the prefix variable as supplied. Then remove the prefix from the message so that the same code can run if there is a prefix or not.
					hasPrefix = true;
					prefix = removechars(message[0], ":");
					message.remove(0);	
				} 

				switch (message[0]) {
					default:
						break;

						//The code to handle these messages should be moved to a dedicated function for each command, however it has been moved to the appropriate message case for a functional program while the command support is small.
					case "USER":
						if(message.length >= 4) { //002 message may not be required.
							clients[clientIndex].setup(message[1], message[2], message[3]);
							clients[clientIndex].queue ~= format("001 %s :Welcome to the Internet Relay Network %s!%s@%s\n", clients[clientIndex].nick, clients[clientIndex].nick, clients[clientIndex].user, clients[clientIndex].host);
							clients[clientIndex].queue ~= format("002 %s :Your host is %s\n", clients[clientIndex].nick, clients[clientIndex].server);
						} else {
							clients[clientIndex].queue ~= "461\n";
						}
						break;

					case "NICK":
						string reqNick = message[1];
						writefln("requested nick: %s", message[1]);
						if (clients[clientIndex].setNick(reqNick)) { //if nick command is sucess.
							writefln("Nick Set: %s", clients[clientIndex].nick);
						} else {
							clients[clientIndex].queue ~= "433\n";
						}
						break;

					case "JOIN": //The way that channel support is implemented here needs to change, but this allows for quick testing of other features until full support for channels as defined in ___ is implemented.
						if (!isChannel(message[1])) {
							channels[message[1]] = new Channel();
						}
						clients[clientIndex].channels ~= message[1];
						writefln("Joined Channel: %s", message[1]);
						break;
					
					//Since these commands have either no support implemented, or a planned and implemented "no support", their code will just live in their appropriate case.
					case "QUIT":
						//No support added for this yet.
						writefln("Received Quit Message");
						break;

					case "CAP": //this server does not support this command.
						clients[clientIndex].queue ~= "421\n";
						break;
				}
			}
		}
	}
}


//This code is deprecated, and should soon br eplaced as a major part of the rewrite.
void processReceived(char[512] buffer, long recLen, size_t index) { //process a message from a client, requires arguments of the message buffer, the length of what was actually received and the index of the client in the client array.
	if (buffer[recLen-1] == '\n') {
		string[] messages = split(to!string(buffer[0.. recLen]), '\n');//first split message by the newline char from the message; a check is done above since it is required, and seperating it makes operating each message easier.
		for (int i=0; i < messages.length; i++) {
			messages[i] = removechars(messages[i], "\r"); //Since irc uses windows-style line endings to show the total end of message, remove the extra character since it is not needed for processing the message.
			if(messages[i].length > 0) {
				string[] message = split(messages[i], " "); //split the message into individual args
				if(buffer[0] != ':') { //if there is no prefix
					if(message[0] == "NICK") {
						string reqNick = message[1];
						writefln("requested nick: %s", message[1]);
						if (clients[index].setNick(reqNick)) { //if nick command is sucess.
							writefln("Nick Set: %s", clients[index].nick);
						} else {
							clients[index].queue ~= "433\n";
						}
					} else if (message[0] == "USER") {
						if(message.length >= 4) {
							clients[index].setup(message[1], message[2], message[3]);
							clients[index].queue ~= format("001 %s :Welcome to the Internet Relay Network %s!%s@%s\n", clients[index].nick, clients[index].nick, clients[index].user, clients[index].host);
							clients[index].queue ~= format("002 %s :Your host is %s\n", clients[index].nick, clients[index].server);
						} else {
							clients[index].queue ~= "461\n";
						}
					} else if (message[0] == "JOIN") {clients[index].channels ~= message[1];
						if (!isChannel(message[1])) {
							channels[message[1]] = new Channel();
						}
						clients[index].channels ~= message[1];
						writefln("Joined Channel: %s", message[1]);
					} else if (message[0] == "CAP") {
						clients[index].queue ~= "421\n";
					}
				}
			}
		}
	}
}
