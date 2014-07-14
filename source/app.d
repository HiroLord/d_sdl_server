import std.stdio;
import std.string;

//SDL
import derelict.sdl2.net;

void main(){

	immutable ushort CLIENTS_ALLOWED;

	// Load the library
	DerelictSDL2Net.load();

	// Setup our sockets and whatnot
	TCPsocket socket;
	IPaddress ip;
	IPaddress *remoteIP;

	Client clients[CLIENTS_ALLOWED];

	// The buffer we will read all data into
	char buffer[512];

	if (SDLNet_Init() < 0) {
		writeln("SDLNet failed to init: ", SDLNet_GetError());
		return;
	}

	SDLNet_SocketSet socketSet = SDLNet_AllocSocketSet(CLIENTS_ALLOWED);
	if (!socketSet) {
		writeln("SDLNet AllocSocketSet failed: ", SDLNet_GetError());
		return;
	}

	// Begins a listening connection on port 2000
	if (SDLNet_ResolveHost(&ip, null, 1234) < 0) {
		writeln("SDLNet ResolveHost failed: ", SDLNet_GetError());
		return;
	}

	// The socket to listen on
	socket = SDLNet_TCP_Open(&ip);
	if (!socket) {
		writeln("SDLNet TCPOpen failed: ", SDLNet_GetError());
	}
	SDLNet_TCP_AddSocket(socketSet, socket);

	bool running = true;

	while (running) {
		int amnt = SDLNet_CheckSockets(socketSet, 0);
		if (amnt > 0){
			writeln("Data is ready to be processed: ", amnt);
		}

		if (SDLNet_SocketReady(socket) != 0){
			writeln("New connection");
			// Listening for an incoming client connection
			for (int i = 0; i < CLIENTS_ALLOWED; i++){
				if (clients[i] is null){
					clients[i] = new Client(SDLNet_TCP_Accept(socket));
					SDLNet_TCP_AddSocket(socketSet, clients[i].socket);
					break;
				}
			}

			/* Contains calls that don't work here...
			remoteIP = SDLNet_TCP_GetPeerAddress(clientSocket);
			if (remoteIP)
				writef("Host connected: %x %d \n", SDLNet_Read32(remoteIP.host), SDLNet_Read16(remoteIP.port));
			else
				writeln("SDLNet TCP_GetPeerAddress failed: ", SDLNet_GetError());
			*/
		}
		for (int j = 0; j < CLIENTS_ALLOWED; j++){
			if (clients[j] !is null){
				if (SDLNet_SocketReady(clients[j].socket)){
					writeln("Data on socket");
					int len;
					/* Listen for an incomming message */
					if ((len = SDLNet_TCP_Recv(clients[j].socket, &buffer, 512)) > 0) {
						writef("Rec: %d | ", len);
						writef("Client said: ");
						for (int i = 0; i < len; i++){
							writef("%s", buffer[i]);
						}
						writeln("");
					} else {
						SDLNet_TCP_Close(clients[j].socket);
					}
				}
			}
		}
	}

	SDLNet_FreeSocketSet(socketSet);
	SDLNet_TCP_Close(socket);
	SDLNet_Quit();
}

class Client{

	TCPsocket socket;

	this(TCPsocket socket){
		this.socket = socket;
	}

}