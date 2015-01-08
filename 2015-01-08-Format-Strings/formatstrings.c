#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include "formatstrings.h"

int main(int argc, char **argv) {

	printf("argc: %d", argc);

	if ( argc  == 2 ) {
		int x = 0;
		x = (int) strtol(argv[1], (char**)NULL, 10);
		if (0 < x && x < 4) {
			main_menu(x);
		}
		else {
			print_exit("M - Incorrect parameter entered.", errno, NULL);
		}
	}
	else if (argc > 2) {
		printf("Usage: %s [1] | [2] | [3]\nExiting..\n",
				argv[0]);
	}
	else {
		printf("%s",
				"Welcome to DC612 January 2015\n"
				"Tonight, we are going to play with some basic format string exploitation.\n"
				"Feel free to ask all those pesky questions, and enjoy yourself!\n"
			  );

		main_menu(0);
	}

	printf("%s\n", "Thanks for playing!");
	exit(0);
};

int main_menu( int choice ) {

	int ret = 0;
	char  buf[3];

	if (choice == 0) {
		printf("%s ",
				"Which challenge would you like to attempt?\n"
				"1) Reading memory\n"
				"2) Modifying memory\n"
				"3) Controling execution\n"
				"4) Quit\n"
				"Enter your option:"
			  );

		fgets( buf, 3, stdin);
		ret=strtol( buf, NULL, 0);

		if(ret == 0) {
			print_exit("MM - Failed to input a proper integer", errno, NULL);
		}

		if (ret > 4) {
			printf("%s", "That is not a valid option\n\n");
			return main_menu(0);
		}
	}
	else if (0 < choice && choice < 4) {
		ret = choice;
	}

	if (1 == ret) challenge_1();
	else if (2 == ret) challenge_2();
	else if (3 == ret) challenge_3();

	return;
}

void challenge_1(void) {

	sploitme *s = reset_struct();

	printf("%s%s\n%s ",
			"\nChallenge 1 - Reading Memory\n"
			"In this challenge, you must read memory off the stack.\n"
			"The specific key you are looking for is\n", s->canary,
			"Buffer please:" 
		  );
	fflush(stdout);
	if (scanf("%s", (s->ui)) == EOF) {
		print_exit("C1 - Failed to provide a valid string", errno, s);
	}

	PRINT_UI();
	FREE_S();
	return;
}

void challenge_2(void) {

	sploitme *s = reset_struct();

	printf("%s%s%8x\n%s ",
			"\nChallenge 2 - Modifying Memory\n",
			"This time, you will need to modify memory at the location\n",
			&(s->improtected),
			"Buffer please:"
		  );
	fflush(stdout);
	if (scanf("%s", s->ui) == EOF) {
		print_exit("C2 - Failed to provide a valid string", errno, s);
	}

	PRINT_UI();

	if (! strncmp(s->canary, CANARY, 21) && s->improtected != IMPROTECTED) {
		printf("%s", "Nice job, you win!\n");
	}
	else {
		printf("%s", "Sorry, that was not correct\n");
	}

	FREE_S();
	return;
}

void challenge_3(void) {

	sploitme *s = reset_struct();

	printf("%s ",
			"\nChallenge 3 - Controlling Execution\n"
			"There is no way to win...\n"
			"Give up now:"
		  );
	fflush(stdout);
	if (scanf("%s", s->ui) == EOF) {
		print_exit("C3 - Failed to provide a valid string", errno, s);
	}

	PRINT_UI();
	(*(s->fp))();
	FREE_S();
	exit(0);
}

void losing(void) {

	printf("%s", "Sorry the I told you, you could not win LULZ.\n");
}

void winning(void) {

	printf("Congrats, you beat the final challenge!\n");
	exit(0);
}

sploitme *reset_struct(void) {

	sploitme *s = NULL;

	if (! (s = malloc(sizeof(sploitme)))) {
		print_exit("RS - Failed to malloc for struct", errno, s);
	}
	if (! (memset(s, '\0', sizeof(sploitme)))) {
		print_exit("RS - Failed to memset struct", errno, s);
	}

	if (! (s->ui = malloc(BUF_SZ))) {
		print_exit("RS - Failed to malloc for ui", errno, s);
	}
	if (! memset(s->ui, '\0', BUF_SZ)) {
		print_exit("RS - Failed to memset ui", errno, s);
	}

	if (! (s->canary = strndup(CANARY, strlen(CANARY)))) {
		print_exit("RS - Faild to memset struct", errno, s);
	}

	s->improtected = IMPROTECTED;
	s->changeme = CHANGEME;
	s->fp = losing;

	return s;
}

void print_exit(const char msg[MAX_MSG], int errnum, sploitme *s) {

	fprintf(stderr, "%s - %s\n", msg, strerror(errnum));
	FREE_S();
	exit(1);
}
