import std.stdio;
import std.socket;

Client[] clients;
Nick[string] nicks;

class Client {
  Socket conn;
  string nick;
  string user;
  string host;
  string server;
  string name;
  string[] queue;
  string[] channels;
  this(Socket connection, string nickname, string username, string hostname, string servername, string realname) {
	user = username;
	host = hostname;
	server = servername;
	name = realname; 
	conn = connection;
	setNick(nickname);
  }
  bool setNick(string newNick) { //Try to set the clients nickname to the supplied argument. Return a the status of setting the new nick.
    if(!nickInUse(newNick)) {
      nicks[nick].release();
      nick = newNick;
      nicks[nick].take();
      return true;
    } else {
      return false;
    }
  }
  void leave() {
    nicks[nick].release();
  }
}

class Nick {
  int status; //0: available, 1: in-use, 2: reserved?
  string contents;
  this(int initStatus, string name) {
    status = initStatus;
    contents=name;
  }
  void release() {
    //change when adding nickname registration to change to reserved if that was its status before use, and if not, remove from array. use nicks.remove(contents); to do so.
    status = 0;
  }
  void take() {
    status = 1;
  }
}

//functions used to interact with clients
int getNickStatus(string checkNick) {
  Nick* check;
  check = (checkNick in nicks);
  if (check == null) { //if nick is not in use or registered
    nicks[checkNick] = new Nick(0, checkNick);
    return 0;
  } else {
    return nicks[checkNick].status;
  }
}
