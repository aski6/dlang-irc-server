import std.stdio;
import std.socket;
class Client {
  Socket conn;
  this(Socket connection) {
    conn = connection;
  }
}
