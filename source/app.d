import std.stdio;
import std.string;

//SDL
import derelict.sdl2.net;

void main(){
	DerelictSDL2Net.load();

	TCPsocket socket, clientSocket;
	IPaddress ip;
	IPaddress *remoteIP;

	char buffer[512];

	if (SDLNet_Init() < 0) {
		writeln("SDLNet failed to init: ", SDLNet_GetError());
		return;
	}

	if (SDLNet_ResolveHost(&ip, null, 2000) < 0) {
		writeln("SDLNet ResolveHost failed: ", SDLNet_GetError());
		return;
	}

	socket = SDLNet_TCP_Open(&ip);
	if (!socket) {
		writeln("SDLNet TCPOpen failed: ", SDLNet_GetError());
	}

	bool running = true;

	while (running) {
		clientSocket = SDLNet_TCP_Accept(socket);
		if (clientSocket) {
			remoteIP = SDLNet_TCP_GetPeerAddress(clientSocket);
			/*
			if (remoteIP)
				writef("Host connected: %x %d \n", SDLNet_Read32(remoteIP.host), SDLNet_Read16(remoteIP.port));
			else
				writeln("SDLNet TCP_GetPeerAddress failed: ", SDLNet_GetError());
			*/

			bool listening = true;
			while (listening) {
				int len;
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