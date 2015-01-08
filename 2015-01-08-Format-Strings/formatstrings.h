#define BUF_SZ  2048
#define MAX_MSG 128
#define CHANGEME 1234567890
#define CANARY "C4t(h_M3_iF_Y0u_C4n!"
#define IMPROTECTED     0xDEADBEEFUL

#define PRINT_UI()      printf("%s ", "You entered:"); \
                        printf(s->ui); \
                        printf("\n\n")

#define FREE_S()        if (s) { \
				if (s->ui) free(s->ui); \
				if (s->canary) free(s->canary); \
                        	free(s); \
			}

typedef struct {
	void (*fp)(void); 
	unsigned int improtected;
	char *canary;
	unsigned int changeme;
	char *ui;
} sploitme;

int main(int argc, char **argv);
int main_menu(int choice);
void challenge_1(void);
void challenge_2(void);
void challenge_3(void);

void losing(void);
void winning(void);
sploitme *reset_struct(void);
void print_exit(const char msg[MAX_MSG], int errnum, sploitme *s);
void winning(void);
