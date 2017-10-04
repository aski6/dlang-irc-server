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

	/*
	   If the message is not valid, we can't process it so exit this function early.
	   All valid messages will end with "\n".
	*/
	if (buffer[recLen-1] != '\n') { //If the message is valid. all valid messages end with \n.
		return;
	}
	//Split the data into separate messages, which will each end with \n. \r characters present in some messages are also removed.
	string[] messages = split(removechars(to!string(buffer[0.. recLen]), "\r"), '\n'); 

	for (int i=0; i < messages.length; i++) { //execute this code for each message.
		//Move onto the next message if there is no data in this message.
		if (messages[i].length < 1) {
		       break;
		}
	
		string[] message = split(messages[i], " "); //Split the message into separated arguments. These are always split by spaces.
		bool hasPrefix = false;
		string prefix;
		/*
		   If the message has a prefix, set the prefix status to true and put the prefix contents into the dedicated string.
		   Then remove the prefix from the message so that the same code can be run with or without a prefix.
		*/
		if (buffer[0] == ':') {
			hasPrefix = true;
			prefix = removechars(message[0], ":");
			message.remove(0);	
		} 

		switch (message[0]) {
			default:
				break;

			/*
		   	The code to handle these messages should be moved into a dedicated function for each message.
			However, for efficency this will be done when the required updates to these commands are implemented.
			*/	   
			case "USER":
				if(message.length >= 4) { 
					clients[clientIndex].setup(message[1], message[2], message[3]);
					clients[clientIndex].queue ~= format("001 %s :Welcome to the Internet Relay Network %s!%s@%s\n", clients[clientIndex].nick, clients[clientIndex].nick, clients[clientIndex].user, clients[clientIndex].host);
					//002 message may not be required.
					clients[clientIndex].queue ~= format("002 %s :Your host is %s\n", clients[clientIndex].nick, clients[clientIndex].server);
					clients[clientIndex].active = true;
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
			//This channel support is temporary, and is used to test other features.
			case "JOIN": 
				if (!isChannel(message[1])) {
					channels[message[1]] = new Channel();
				}
				clients[clientIndex].channels ~= message[1];
				writefln("Joined Channel: %s", message[1]);
				break;

			case "PRIVMSG":
				privmsg(clientIndex, message[1], message[2.. message.length]);
				break;	
			//These commands have either have a direct reply/action, or a planned "no support" response.
			case "PING":
				clients[clientIndex].queue ~= format("PONG %s\n", clients[clientIndex].server);
				break;

			case "QUIT":
				writefln("Received quit message, releasing nickname and closing sockets");
				clients[clientIndex].quit(to!int(clientIndex));
				clients = clients.remove(clientIndex);
				break;

			case "CAP": //this server does not support this command.
				clients[clientIndex].queue ~= "421\n";
				break;
		}
	}
}

//specific functions for running irc commands.
void privmsg(size_t index, string target, string[] message) {
	string[] targets = split(target, ",");
}
