import client;
Channel[string] channels;

class Channel {
	string id;
	string[] queue;
	this(string name) {
		id = name;
	}
}

class Message {
	string data;
	this(string contents) {
		data = contents;
	}
}

int checkChannelExistance(string channelName) {
  Channel* check;
  check = (channelName in channels);
  if (check == null) { //if channel is not yet created.
    return false;
  } else {
    return true;
  }
}
