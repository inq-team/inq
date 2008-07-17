/*
 * Initialized FTDI-based thermometer devices on ttyUSB0
 * (C) GreyCat <greycat@altlinux.org> 2005
 *
 * Based on ttydevinit by Guido Socher 
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

int main(int argc, char *argv[])
{
	struct termios portset;
	int fd;
	
	FILE *f;
	char search_cmd[3] = { 0xDB, 0x00, 0x7B };
	char search_buf[256];
	int count;

        /* Open port */
        fd = open("/dev/ttyUSB0", O_RDWR | O_NOCTTY | O_NDELAY);
        if (fd == -1) {
		perror("ERROR: open failed");
		exit(1);
        }

	/* Set up port settings */
        tcgetattr(fd, &portset);
	cfmakeraw(&portset);
	cfsetospeed(&portset, B115200);
	cfsetispeed(&portset, B115200);
	tcsetattr(fd, TCSANOW, &portset);

	close(fd);

	/* Search for sensors */
	f = fopen("/dev/ttyUSB0", "r+");
	count = fwrite(search_cmd, 1, 3, f);
	if (count < 1) {
		perror("ERROR: search sensor write failed");
		exit(1);
	}
	
	/* Read sensors report back */
	count = fread(search_buf, 1, 3 + 8 * 16 + 1, f);
	if (count < 1) {
		perror("ERROR: search sensor read failed");
		exit(1);
	}

	close(fd);
	return(0);
}
