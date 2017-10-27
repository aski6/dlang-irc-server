import std.stdio;
import std.socket;
import std.algorithm.mutation;
import std.format;

bool[string] nicks;
Client[] clients;

class Client {
  Socket conn;
  bool active = false;

  string nick;

  string username;
  string hostname;
  string servername;
  string realName;

  string[] queue;
  string[] channels;

  this(Socket connection) {
	conn = connection;
  }

  void setup(string username, string hostname, string servername, string realname) {
	this.username = username;
	this.hostname = hostname;
	this.servername = servername;
	this.realName = realname;

	active = true;
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
    writefln("nick removed");
    //conn.shutdown();
    conn.close();
    writefln("connection closed");
    //clients.remove(clientsIndex);
  }
}


//functions used to interact with clients
bool nickInUse(string target) {
  bool* check;
  check = (target in nicks);
  return (check != null); //return boolean based on if the check result is null or not.
}
