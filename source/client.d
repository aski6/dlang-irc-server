/*
Copyright (C) 2017-2018  aski6

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
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
