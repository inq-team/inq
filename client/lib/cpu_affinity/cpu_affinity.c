/* cpu_affinity - command-line tool to set CPU affinity of a task */

#include <stdlib.h>
#include <stdio.h>
#include <sched.h>

int main(int argc, char *argv[])
{
	unsigned long new_mask;
	unsigned long cur_mask;
	unsigned int len = sizeof(new_mask);
	pid_t pid;

	if(argc != 3){
		fprintf(stderr, "usage: %s [pid] [cpu_mask]\n", argv[0]);
		return(-1);
	};

	pid = atol(argv[1]);
	sscanf(argv[2], "%08lx", &new_mask);

	if(sched_getaffinity(pid, len, &cur_mask) < 0){
		perror("sched_getaffinity");
		return(-1);
	};

	printf("pid %d's old affinity: %08lx\n", pid, cur_mask);

	if(sched_setaffinity(pid, len, &new_mask)){
		perror("sched_setaffinity");
		return(-1);
	};

	if(sched_getaffinity(pid, len, &cur_mask) < 0){
		perror("sched_getaffinity");
		return(-1);
	};

	printf(" pid %d's new affinity: %08lx\n", pid, cur_mask);

	return(0);
}
