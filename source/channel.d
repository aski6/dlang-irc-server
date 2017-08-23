import client;

class Channel {
	string[] queue;
	this() {
	}
}

int isChannel(string name) {
  Channel* check;
  check = (name in channels);
  if (check == null) { //if channel is not yet created.
    return false;
  } else {
    return true;
  }
}
