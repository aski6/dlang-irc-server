import std.stdio;
import std.socket;

int[string] nicks;

class Client {
  Socket conn;
  string nick;
  this(Socket connection, string nickname) {
    conn = connection;
    nick = nickname;
  }
  bool setNick(string newNick) {
    int* check;
    check = (newNick in nicks);
    if (check == null) { //if nick is not in use or registered
      nicks.remove(nick);
      nick = newNick;
      nicks[newNick] = 0;
    } //add code for reserved usernames later(state 1)
  }
}
