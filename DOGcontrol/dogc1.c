/*-----------------------------------------------------------------------------
About
Author:		WigWag (Travis Mccollum)
Hardware: 	Watchdog and Led board.  (DOG)
Purpose:		Communicates LED, Watchdog, and Sound control
References:
			http://crasseux.com/books/ctutorial/Processing-command-line-options.html#Processing%20command-line%20options
			http://man7.org/linux/man-pages/man3/termios.3.html
	
Protocol:  I am going to use a simple ASCII readable protocol to pass data, however, numbers will be in hex, using an unsigned char (0-255)
	help on this can be viewed here: https://docs.google.com/spreadsheets/d/1a8K70RtRaYrRI1oDdWF6nlBpLg-wneg7XPUcpw40KS4/edit#gid=123753022
	The frame is 20 characters and can be represented by a char[] array
	char[0]:	start character, ^ //note: you cannot use ^ in your data, anything else is considered an error flag
	char[18]:	checksum (remainder of sum all uint8/32) //note: this can come early, just follow with a $
	char[19]:	end of frame, $ is expected //note: you can end early with a $.  You cannot use a $ in your data
	char[1]:	mode commands, valid commands are as follows
		 c:		color mode 
		 char[2]:		red color start brightness 000-255 //note  hex 0x00-0xff 
		 char[3]:		green color start brightness 
		 char[4]:		blue color start brightness
		 char[5]:		red color end brightness 000-255 //note  hex 0x00-0xff
		 char[6]:		green color end brightness
		 char[7]:		blue color end brightness
		 char[8]:		transition mode
			  b:		blink
			  f:		fade
			  s:		solid
		 char[9,10]:	transition time in ms //note 2 bytes = 65535ms = 65 secs
		 char[11]:		checksum // 1 byte
		 char[12]:		$ //note, were calling the end early	
		 w:		watchdog mode
		 char[2]:		watchdog mode
			  d:		disable
			  char[3]:	$ //note, were calling the end early
			  e:	enable
			  u:	update
			  char[3]:	set to expire in so many seconds.  0 means expire now //1 byte 0x00-0xff 0-255 seconds
		m:		music mode
-----------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------------------------------------------------------------------------
Includes
------------------------------------------------------------------------------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <sys/signal.h>
#include <errno.h>
#include <termios.h>
#include <argp.h>
#include <errno.h>

/*-----------------------------------------------------------------------------
Structual defines
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Calculation defines
-----------------------------------------------------------------------------*/
#define BAUDRATE B38400
#define REQ_ARG_COUNT	1

/*-----------------------------------------------------------------------------
Function prototypes
-----------------------------------------------------------------------------*/
void signal_handler_IO (int status);   /* definition of signal handler */

/*-----------------------------------------------------------------------------
Global varriables
-----------------------------------------------------------------------------*/
int n;
int fd;
speed_t thisBaud=B38400;
char *outspeed="38400";
int connected;
struct termios tty;
struct termios stdio;
struct termios stdioBefore;
unsigned char c='D';


struct sigaction saio;
char *ttyport = "/dev/ttyUSB4";
/*-----------------------------------------------------------------------------
Public routines
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Interrupt service routines (private)
-----------------------------------------------------------------------------*/
void signal_handler_IO (int status)
{
	//printf("received data from UART.\n");
}
/*-----------------------------------------------------------------------------
Utility routines (private)
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Standard routines (private)
-----------------------------------------------------------------------------*/
const char *argp_program_version =
"dogc 1.0";

const char *argp_program_bug_address =
"<travis@wigwag.com>";

/* This structure is used by main to communicate with parse_opt. */
struct arguments
{
  char *args[REQ_ARG_COUNT];            /* ARG1 and ARG2 */
  int verbose;              /* The -v flag */
  char *outfile;            /* Argument for -o */
  char *string1, *baud;  /* Arguments for -a and -b */
};

/*
   OPTIONS.  Field 1 in ARGP.
   Order of fields: {NAME, KEY, ARG, FLAGS, DOC}.
*/
static struct argp_option options[] =
{
	{"verbose", 'v', 0, 0, "Produce verbose output"},
	{"alpha",   'a', "STRING1", 0, "Do something with STRING1 related to the letter A"},
	{"baud",   'b', "baudrate", 0, "Set the baudrate. [9600 | 19200 | *38400]"},
	{"output",  'o', "OUTFILE", 0, "Output to OUTFILE instead of to standard output"},
	{0}
};


//Argument PARSER. Field 2 in ARGP.  Order of parameters: KEY, ARG, STATE.
static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
	struct arguments *arguments = state->input;
	int compare;
	switch (key)
	{
		case 'v':
		arguments->verbose = 1;
		break;
		case 'a':
		arguments->string1 = arg;
		break;
		case 'b': NULL;
		if (strcmp(arg,"B9600")==0 || strcmp(arg,"9600")==0){
			thisBaud=B9600;
			outspeed="9600";
		}
		else if (strcmp(arg,"B19200")==0 || strcmp(arg,"19200")==0){
			thisBaud=B19200;
			outspeed="19200";
		}
		else if (strcmp(arg,"B38400")==0 || strcmp(arg,"38400")==0){
			thisBaud=B38400;
		}
		else {
			fprintf(stderr, "Incorrect baudrate provided:  %s\n", arg);
			argp_usage(state);
			exit(1);
		}
		arguments->baud=arg;

		break;
		case 'o':
		arguments->outfile = arg;
		break;
		case ARGP_KEY_ARG:
		if (state->arg_num >= REQ_ARG_COUNT)
		{
			argp_usage(state);
		}
		arguments->args[state->arg_num] = arg;
		break;
		case ARGP_KEY_END:
		if (state->arg_num < REQ_ARG_COUNT)
		{
			argp_usage (state);
		}
		break;
		default:
		return ARGP_ERR_UNKNOWN;
	}
	return 0;
}

//ARGS_DOC. Field 3 in ARGP.  A description of the non-option command-line arguments that we accept.
//static char args_doc[] = "ARG1 ARG2"; 
static char args_doc[] = "TTY";

//DOC.  Field 4 in ARGP.  Program documentation.

static char doc[] ="dogc -- A program to control the DOG board, which consists of the tri-state LED, Piezo buzzer, and system watchdog.  \vA WigWag Core Program.";

//The ARGP structure itself.
static struct argp argp = {options, parse_opt, args_doc, doc};




/*-----------------------------------------------------------------------------
main
-----------------------------------------------------------------------------*/
int main(int argc, char **argv) {
	struct arguments arguments;
	FILE *outstream;

  /* Set argument defaults */
	arguments.outfile = NULL;
	arguments.string1 = "";
	arguments.baud ="";
	arguments.verbose = 0;

  /* Where the magic happens */
	argp_parse (&argp, argc, argv, 0, 0, &arguments);

  /* Where do we send output? */
	if (arguments.outfile)
		outstream = fopen (arguments.outfile, "w");
	else
		outstream = stdout;
	ttyport=arguments.args[0];

  /* Print argument values */
	// fprintf (outstream, "alpha = %s\nbaud = %s\n\n",
	// 	arguments.string1, arguments.baud);
	// fprintf (outstream, "TTY = %s\nARG2 = %s\n\n",
	// 	arguments.args[0],
	// 	arguments.args[1]);

  /* //Access verbose flag this way:
	if (arguments.verbose)
		printf("testing the verbose flag")
	*/
	
	tcgetattr(STDOUT_FILENO,&stdioBefore);

     fd = open(ttyport, O_RDWR | O_NOCTTY | O_NDELAY);   //READ & WRITE, port never becomes the controlling terminal, Non-blocking
     if (fd == -1) {
     	fprintf(stderr, "open_port: Unable to open %s\nError No: %d\n", ttyport,errno);
     	perror("Error Message");
     	exit(1);
     }
     if(!isatty(fd)) {
     	fprintf(stderr, "%s does not appear to be a valid TTY\n", ttyport);
     	perror("");
     	exit(1);	
     }
     saio.sa_handler = signal_handler_IO;
     saio.sa_flags = 0;
     saio.sa_restorer = NULL; 
     sigaction(SIGIO,&saio,NULL);

     fcntl(fd, F_SETFL, FNDELAY);
     fcntl(fd, F_SETOWN, getpid());
    // fcntl(fd, F_SETFL,  O_ASYNC ); 	//makes the interrupt handler work ???
     //fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);       // make the reads non-blocking

     if(tcgetattr(fd,&tty) < 0 ) {
     	fprintf(stderr, "%s is not returning a configuration.\n", ttyport);
     	perror("");
     	exit(1);
     }
     if (cfsetispeed(&tty,thisBaud) < 0 || cfsetospeed(&tty,thisBaud) < 0) {
     	fprintf(stderr, "%s is not accepting baud rate. %s \n", ttyport,thisBaud);
     	perror("");
     	exit(1);
     }

     memset(&stdio,0,sizeof(stdio));
     stdio.c_iflag=0;
     stdio.c_oflag=0;
     stdio.c_cflag=0;
     stdio.c_lflag=0;
     stdio.c_cc[VMIN]=1;
     stdio.c_cc[VTIME]=0;
     tcsetattr(STDOUT_FILENO,TCSANOW,&stdio);
     tcsetattr(STDOUT_FILENO,TCSAFLUSH,&stdio);
     fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK); 

     //blank out the $tty struct
     memset(&tty,0,sizeof(tty));
     //Line Processing flags:
     //tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ECHONL | ISIG); 
     tty.c_lflag &=~ICANON; 		//canonical mode 
     tty.c_lflag &=~ECHO; 			//echo mode 
     tty.c_lflag &=~ECHOE;			//If ICANON, erase character erases the preceding input character, and WERASE erases the preceding word.
     tty.c_lflag &=~ECHONL;			//IF ICANON, echo the NL char even if echo is not set
     tty.c_lflag &=~ECHOK;			//IF ICANON, the kill character erases the current line
     tty.c_lflag &=~ISIG;			//Signal chars 

     //input flags
     //tty.c_iflag &= ~(IXON | IXOFF | IXANY;
     tty.c_iflag &=~IXON;			//XON/XOFF software flow control on output
     tty.c_iflag &=~IXOFF;			//XON/OFF software flow control on input
     tty.c_iflag &=~IXANY;			//Typing any character will restart stopped output.
     tty.c_iflag &=~IGNBRK;			//Ignore carriage return on input
     tty.c_iflag &=~INLCR;			//Translate NL to CR on input.
     tty.c_iflag &=~ICRNL;			//Translate CR to NL on input.
     tty.c_iflag &=~BRKINT;			//If IGNBRK is set, a BREAK is ignored.  If it is not set but BRKINT is set, then a BREAK causes the input and output queues to be flushed, and if the terminal is the controlling terminal of a foreground process group, it will cause a SIGINT to be sent to this foreground process group.  When neither IGNBRK nor BRKINT are set, a BREAK reads as a null byte ('\0', except when PARMRK is set, in which case it reads as the sequence \377 \0 \0.
     tty.c_iflag &=~PARMRK;			//If this bit is set, input bytes with parity or framing errors are marked when passed to the program.  This bit is meaningful only when INPCK is set and IGNPAR is not set.  The way erroneous bytes are marked is with two preceding bytes, \377 and \0.  Thus, the program actually reads three bytes for one erroneous byte received from the terminal.  If a valid byte has the value \377, and ISTRIP (see below is not set, the program might confuse it with the prefix that marks a parity error.  Therefore, a valid byte \377 is passed to the program as two bytes, \377 \377, in this case. If neither IGNPAR nor PARMRK is set, read a character with a parity error or framing error as \0.
     tty.c_iflag &=~INPCK;			//Enable input parity checking.
     tty.c_iflag &=~ISTRIP;			//Strip off eighth bit.
     
     //output flags
     //tty.c_oflag &= ~OPOST;
     // Output flags - Turn off output processing
	//
	// no CR to NL translation, no NL to CR-NL translation,
	// no NL to CR translation, no column 0 CR suppression,
	// no Ctrl-D suppression, no fill characters, no case mapping,
	// no local output processing
	//
	// tty.c_oflag &= ~(OCRNL | ONLCR | ONLRET |
	//                     ONOCR | ONOEOT| OFILL | OLCUC | OPOST);
     tty.c_oflag = 0;

     tty.c_cflag &= ~PARENB;			//parity checking
     tty.c_cflag &= ~CSTOPB;			//set two stop bits
     tty.c_cflag &= ~CSIZE;			//current char size mark

     							//8n1:
     tty.c_cflag |= CS8;				//force 8 bit input
     tty.c_cflag |= CLOCAL;			//Ingore modem control lines
     tty.c_cflag |= CREAD;			//enable receiver

     tty.c_cc[VMIN]  = 0;			//1 will block and wait for 1 character
     tty.c_cc[VTIME] = 0;			//timer will timeout after x time

     tcsetattr(fd,TCSANOW,&tty);		//the change occurs immedately
     //tcsetattr(fd,TCSADRAIN,&tty);	//the change occurs after all output written to fd has been transmitted.  This option should be used when changing parameters that affect output.
     //tcsetattr(fd,TCSAFLUSH,&tty);	//the change occurs after all output written to the object referred by fd has been transmitted, and all input that has been received but not read will be discarded before the change is made.
     printf("%s connecting at %s \n",ttyport,outspeed);
     //exit(1);
     connected = 1;
     // while(connected == 1){
     // 	sleep(4);
     // 	printf("slept 4");
     // }
     while (c!='q')
     {
                if (read(fd,&c,1)>0)        write(STDOUT_FILENO,&c,1);              // if new data is available on the serial port, print it out
                if (read(STDIN_FILENO,&c,1)>0)  write(fd,&c,1);                     // if new data is available on the console, send it to the serial port
           }

           close(fd);
           tcsetattr(STDOUT_FILENO,TCSANOW,&stdioBefore);
           exit(0);             
      }

