module network.network;

import core.thread;

import vibe.core.core;
import vibe.core.net;
import vibe.stream.operations;

enum int PORT = 9077;

shared static this() {
	disableDefaultSignalHandlers();
}

void networkThread() {
	version(Client) {
		TCPConnection con = connectTCP("localhost", PORT);
		handleConnection(con);
	}
	version(Server) {
		auto listeners = listenTCP(PORT, con => handleConnection(con));
		runApplication();
		foreach (listener; listeners) {
			listener.stopListening();
		}
		import core.stdc.stdlib: exit;
		exit(0);
	}
}

version(Client)
void handleConnection(TCPConnection con) {
	while (con.waitForData) {
		string text = cast(string) con.readLine();
		import render.screen: debugText;
		debugText = cast(shared(string)) text;
	}
}

version(Server)
@trusted nothrow void handleConnection(TCPConnection con) {
	try {
		con.write("gamer mode\r\n");
		Thread.sleep(dur!"seconds"(1));
		con.write("epic style\r\n");
	} catch (Exception e) {

	}
}