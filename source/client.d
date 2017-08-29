import std.stdio;
import std.socket;
import std.algorithm.mutation;
import std.format;

bool[string] nicks;
Client[] clients;

class Client {
  Socket conn;

  string nick;

  string user;
  string host;
  string server;

  string[] queue;
  string[] channels;

  this(Socket connection, string nickname) {
	conn = connection;
	while (!setNick(nickname)) {
	  nickname = format("%s%s", nickname, "_");
	}
  }

  void setup(string username, string hostname, string servername) {
	user = username;
	host = hostname;
	server = servername;
  }

  bool setNick(string newNick) { //Try to set the clients nickname to the supplied argument. Return a the status of setting the new nick.
    if(!nickInUse(newNick)) {
      nicks.remove(nick);
      nick = newNick;
      nicks[nick] = true;
      return true;
    } else {
      return false;
    }
  }
  
  void quit(int clientsIndex) {
    nicks.remove(nick);
    clients.remove(clientsIndex);
  }
}


//functions used to interact with clients
bool nickInUse(string target) {
  bool* check;
  check = (target in nicks);
  return (check != null); //return boolean based on if the check result is null or not.
}
