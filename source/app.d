import std.stdio;
import std.string;

//SDL
import derelict.sdl2.net;

void main(){
	// Load the library
	DerelictSDL2Net.load();

	// Setup our sockets and whatnot
	TCPsocket socket, clientSocket;
	IPaddress ip;
	IPaddress *remoteIP;

	// The buffer we will read all data into
	char buffer[512];

	if (SDLNet_Init() < 0) {
		writeln("SDLNet failed to init: ", SDLNet_GetError());
		return;
	}

	// Begins a listening connection on port 2000
	if (SDLNet_ResolveHost(&ip, null, 2000) < 0) {
		writeln("SDLNet ResolveHost failed: ", SDLNet_GetError());
		return;
	}

	// The socket to listen on
	socket = SDLNet_TCP_Open(&ip);
	if (!socket) {
		writeln("SDLNet TCPOpen failed: ", SDLNet_GetError());
	}

	bool running = true;

	while (running) {
		// Listening for an incoming client connection
		clientSocket = SDLNet_TCP_Accept(socket);
		if (clientSocket) {
			/* Contains calls that don't work here...
			remoteIP = SDLNet_TCP_GetPeerAddress(clientSocket);
			
			if (remoteIP)
				writef("Host connected: %x %d \n", SDLNet_Read32(remoteIP.host), SDLNet_Read16(remoteIP.port));
			else
				writeln("SDLNet TCP_GetPeerAddress failed: ", SDLNet_GetError());
			*/

			bool listening = true;
			while (listening) {
				int len;
				/* Listen for an incomming message */
				if ((len = SDLNet_TCP_Recv(clientSocket, &buffer, 512)) > 0) {
					writef("Rec: %d | ", len);
					writeln("Client said: ", buffer);
					listening = false;
					running = false;
				}
			}
			SDLNet_TCP_Close(clientSocket);
		}
	}

	SDLNet_TCP_Close(socket);
	SDLNet_Quit();
}