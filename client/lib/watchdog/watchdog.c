/*
 * client/watchdog/watchdog.c - A part of Inquisitor project
 * Copyright (C) 2004-2008 by Iquisitor team 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#define SUCCESS 0
#define ERROR   1

#define MAX_MSG 256

#define SERVER_PORT	8330
#define CLIENT_PORT	4321

/* 
 * Down there, "server" is local machine that sleeps and answers pings
 * and "client" is somebody who wants to get a reply at their ping
 * request (i.e. real inquisitor server).
 */

int main (int argc, char *argv[])
{
	int recvSock, sendSock;

 	struct sockaddr_in cliAddr;
	struct sockaddr_in servAddr;
	char msg[MAX_MSG];

	/* create sockets */
	recvSock = socket(AF_INET, SOCK_DGRAM, 0);
	if (recvSock < 0) {
		perror("Can't open socket");
		return ERROR;
	}

	sendSock = socket(AF_INET, SOCK_DGRAM, 0);
	if (recvSock < 0) {
		perror("Can't open socket");
		return ERROR;
	}

	/* bind server port */
	servAddr.sin_family = AF_INET;
	servAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servAddr.sin_port = htons(SERVER_PORT);

	if (bind(recvSock, (struct sockaddr *) &servAddr, sizeof(servAddr))<0) {
		perror("Can't bind port");
		return ERROR;
	}

	for (;;) {
		socklen_t cliAddrLen;

		recvfrom(recvSock, msg, sizeof(msg), 0, (struct sockaddr *) &cliAddr, &cliAddrLen);
//		printf("Ping received\n");
		
//		printf("cliAddr.sin_port=%d\n", cliAddr.sin_port);

		cliAddr.sin_port = htons(CLIENT_PORT);

		msg[0] = '!';
		msg[1] = 0;
 		sendto(sendSock, msg, 1, 0, (struct sockaddr *) &cliAddr, cliAddrLen);
// 		printf("Reply sent\n");
	}

	return SUCCESS;
}
