import std.stdio;
import std.socket;

class Message {
  Socket origin;
  char[] contents;
  this (Socket from, string message) {
    origin = from;
    contents = message;
  }
}
