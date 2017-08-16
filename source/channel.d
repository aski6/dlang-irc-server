import client;

class Channel {
	string id;
	string[] queue;
	this(string name) {
		id = name;
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
