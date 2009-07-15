#include <stdio.h>

#define SLEEP_TIME 250000

int main() {
	char t[4] = "\\-/|";
	long i = 0;
	while (1) {
		printf("%c\n", t[i]);
		i = (i + 1) % 4;
		usleep(SLEEP_TIME);
	};
}
