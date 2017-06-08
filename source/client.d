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
  bool active = false;
  this(Socket connection, string nickname) {
    conn = connection;
    setNick(nickname);
  }
  void setup(string username, string hostname, string servername, string realname) {
    user = username;
    host = hostname;
    server = servername;
    name = realname;
    active = true;
  }
  int setNick(string newNick) { //returns 0 for success, 1 for failure. handling for reserved to be done later.
    if(getNickStatus(newNick) == 0) {
      nick = newNick;
      nicks[nick].take();
      return 0;
    } else {
      //change this when adding nickname registration
      return 1;
    }
  }
  void joinChannel(string channel) {

  }
  void leaveChannel(string channel) {

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
