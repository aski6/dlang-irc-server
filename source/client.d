import std.stdio;
import std.socket;

Client[] clients;
Nick[string] nicks;

class Client {
  Socket conn;
  string nick;
  this(Socket connection, string nickname) {
    conn = connection;
    setNick(nickname);
  }
  int setNick(string newNick) { //returns 0 for success, 1 for failure. handling for reserved to be done later.
    int stat = getNickStatus(newNick);
    if(stat == 0) {
      nick = newNick;
      nicks[nick].take();
      return 0;
    } else {
      //change this when adding nickname registration
      return 1;
    }
  }
}

class Nick {
  int status; //0: available, 1: in-use, 2: reserved?
  this(int initStatus) {
    status = initStatus;
  }
  void release() {
    //change when adding nickname registration
    status = 0;
  }
  void take() {

  }
}


//functions used to interact with clients

int getNickStatus(string checkNick) {
  Nick* check;
  check = (checkNick in nicks);
  if (check == null) { //if nick is not in use or registered
    nicks[checkNick] = new Nick(0);
    return 0;
  } else {
    return nicks[checkNick].status;
  }
}
