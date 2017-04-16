import std.stdio;
import std.socket;

class Message {
  Socket origin;
  char[] contents;
  long length;
  this (Socket from, char[] message, long len) {
    origin = from;
    contents = message;
    length = len;
  }
}
