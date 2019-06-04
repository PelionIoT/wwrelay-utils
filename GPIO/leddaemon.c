/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <dirent.h>
#include <termios.h>
#include <regex.h>
#include <signal.h>
//https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/input.h
#include <linux/input.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/un.h>

//#define debugLED
//define debugechoback

//#define SOCK_PATH "\0led"
char *socket_path="\0led";
FILE *logfile;
// unsigned long GPIO_SLCK = 38;  // gpio1
// unsigned long GPIO_SDATA = 37; // gpio2
char SLCK[100]="/sys/class/gpio/gpio38/value";
char SDATA[100]="/sys/class/gpio/gpio37/value";
//char SLCK[100]="/tmp/slck";
//char SDATA[100]="/tmp/sdata";
int GPIO_SLCK,GPIO_SDATA;
int blinkthread=0;

pthread_t blink_thread;
struct blink_struct {
	unsigned int R1;
	unsigned int G1;
	unsigned int B1;
	unsigned int D1;
	unsigned int R2;
	unsigned int G2;
	unsigned int B2;
	unsigned int D2;
}blink;

int pprintf(const char *fmt,...){
	int n;
	va_list ap;

	va_start(ap, fmt);
	n = fprintf(logfile, fmt, ap);
	va_end(ap);

	return n;
}


static int wigwagled(unsigned long R, unsigned long G, unsigned long B);
void *blink_thread_run (void *arguments);

static init_LED(void) {
	if ((GPIO_SLCK = open(SLCK, O_WRONLY)) == -1){
		printf ("%s is not a vaild file.n", SLCK);
	}
	else {
		printf ("I am ready, %s is a valid file\n",SLCK);
	}
	if ((GPIO_SDATA = open(SDATA, O_WRONLY)) == -1){
		printf ("%s is not a vaild file.n", SDATA);
	}     
	else {
		printf ("I am ready, %s is a valid file\n",SDATA);
	}
}

void processCommand(char *dup2){
	int i,cmp,check;
	char *vars;
	char cmd[20];
	char solidcmd[]="solid";
	vars = strtok(dup2," ");
	//printf("my vars (%s)",vars);
	int vari=atoi(vars);
	//printf("did i break\n");
	//printf("we have %i vars\n",vari);
	char **output = malloc( vari * sizeof(char *) );

	for (i = 0; i < vari; ++i) {
		output[i] = strtok(NULL," ");
		//printf("setting output[%d]=%s\n",i,output[i]);
				// printf("hey %s\n",output[i]);
	}
	#if 0
	printf("lets read output\n");
	for( i = 0; i < vari; ++i ) {
		printf( "output[%d] = (%s)\n", i, output[i] );
	}
	#endif
	// printf("output[0]='%s' ok\n",output[0]);
	// sprintf(cmd,"%s",output[0]);
	// printf("my command '%s'\n",cmd);
	if (output[0]!=NULL){
		cmp=strcmp(output[0],"solid");
		//printf("the compare is %i",cmp);
		if (cmp==0){
			if (blinkthread==1){
				pthread_cancel(blink_thread);
				blinkthread=0;
			}
			wigwagled(atoi(output[1]),atoi(output[2]),atoi(output[3]));
		//wigwagled(1,1,1);
		}
		else{
			printf("not solid\n");
		}
		cmp=strcmp(output[0],"blink");
		if (cmp==0){
			blink.R1=atoi(output[1]);
			blink.G1=atoi(output[2]);
			blink.B1=atoi(output[3]);
			blink.D1=atoi(output[4]);
			blink.R2=atoi(output[5]);
			blink.G2=atoi(output[6]);
			blink.B2=atoi(output[7]);
			blink.D2=atoi(output[8]);
			if (blinkthread==1){
				pthread_cancel(blink_thread);
				blinkthread=0;
			}
			if (pthread_create(&blink_thread, NULL, &blink_thread_run, (void *)&blink) != 0){
				printf("couldn't create the blink thread\n");
				blinkthread=0;
			}
			else {
				blinkthread=1;
			}
		}
		else {
			printf("not blink\n");
		}
	}
}


//char *socket_path="/tmp/led";
//https://github.com/troydhanson/network/tree/master/unixdomain
//http://beej.us/guide/bgipc/output/html/multipage/unixsock.html
static init_socket(void){
	int s, s2, t, len;
	struct sockaddr_un local, remote;
	char str[100];

	if ((s = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
		perror("socket");
		exit(1);
	}

	local.sun_family = AF_UNIX;
	//strcpy(local.sun_path, SOCK_PATH);
	if (*socket_path == '\0') {
		memset(local.sun_path, '\0', sizeof(local.sun_path));
		*local.sun_path = '\0';
		strncpy(local.sun_path+1, socket_path+1, sizeof(local.sun_path)-2);
	} else {
		strncpy(local.sun_path, socket_path, sizeof(local.sun_path)-1);
		unlink(socket_path);
	}


	// strcpy(local.sun_path,socket_path);
	// unlink(local.sun_path);
	len = strlen(local.sun_path) + sizeof(local.sun_family);
	//if (bind(s, (struct sockaddr *)&local, len) == -1) {
	if (bind(s, (struct sockaddr *)&local, sizeof(local)) == -1) {
		perror("bind");
		exit(1);
	}

	if (listen(s, 5) == -1) {
		perror("listen");
		exit(1);
	}
	printf("entering for loop\n");
	for(;;) {
		int done, n;
		printf("Waiting for a connection...\n");
		t = sizeof(remote);
		if ((s2 = accept(s, (struct sockaddr *)&remote, &t)) == -1) {
			perror("accept");
			exit(1);
		}

		printf("Connected.\n");

		done = 0;

		do {
			memset(str, 0, sizeof str);
			n = recv(s2, str, 100, 0);
			if (n <= 0) {
				if (n < 0) {
					perror("recv");
				}
				done = 1;
			}

			if (!done) {
				processCommand(str);
				#ifdef debugechoback
				if (send(s2, str, n, 0) < 0) {
					perror("send");
					done = 1;
				}
				#endif
			}
		} while (!done);
		printf("closing s2\n");
		close(s2);
	}
	printf("returning 0\n");
	return 0;
}





void gpio_direction_output(int fd, char val){
	write(fd, &val, 1);
    //  printf("writting the value: %i\n",val);
}

static int wigwagled(unsigned long R, unsigned long G, unsigned long B){

	int ret = 0;

      //unsigned long R = 0; unsigned long G = 0; unsigned long B = 0;

	unsigned long mask = 16;
	unsigned long maskfilter = 0; 
	int N = 0;

	ret = 2;

	for (N=0;N<32;N++) {
		gpio_direction_output(GPIO_SLCK, '1');            
		gpio_direction_output(GPIO_SLCK, '0');            
	}

	gpio_direction_output(GPIO_SDATA, '1');           
	gpio_direction_output(GPIO_SLCK, '1');            
	gpio_direction_output(GPIO_SLCK, '0');            

	mask = 16;
	for (N=0;N<5;N++) {
		maskfilter = mask & R;
		if(maskfilter == 0) 
			gpio_direction_output(GPIO_SDATA, '0');
		else
			gpio_direction_output(GPIO_SDATA, '1');
		gpio_direction_output(GPIO_SLCK, '1');            
		gpio_direction_output(GPIO_SLCK, '0');      
		mask >>= 1;
	}
	mask = 16;
	for (N=0;N<5;N++) {
		maskfilter = mask & B;
		if(maskfilter == 0) 
			gpio_direction_output(GPIO_SDATA, '0');
		else
			gpio_direction_output(GPIO_SDATA, '1');
		gpio_direction_output(GPIO_SLCK, '1');            
		gpio_direction_output(GPIO_SLCK, '0');      
		mask >>= 1;
	}
	mask = 16;
	for (N=0;N<5;N++) {
		maskfilter = mask & G;
		if(maskfilter == 0) 
			gpio_direction_output(GPIO_SDATA, '0');
		else
			gpio_direction_output(GPIO_SDATA, '1');
		gpio_direction_output(GPIO_SLCK, '1');            
		gpio_direction_output(GPIO_SLCK, '0');      
		mask >>= 1;
	}
	gpio_direction_output(GPIO_SDATA, '0');     
	for (N=0;N<2;N++) {
		gpio_direction_output(GPIO_SLCK, '1');            
		gpio_direction_output(GPIO_SLCK, '0');                  
	}
	#ifdef debugLED
	printf("setting led to:  %i %i %i \n",R,G,B);
	#endif
	return 0;
}
void *blink_thread_run (void *arguments) {
	struct arg_struct *args = (struct arg_struct *)arguments;
	while(1)
	{
		// wigwagled(args.R1,args.G1,args.B1);
		// sleep(args.D1);
		// wigwagled(args.R2,args.G2,args.B2);
		// sleep(args.D2);
		// printf("first %i,%i,%i,time: %i \n",blink.R1,blink.G1,blink.B1,blink.D1);
		// printf("second %i,%i,%i,time: %i\n",blink.R2,blink.G2,blink.B2,blink.D2);
		//sleep(5);
		wigwagled(blink.R1,blink.G1,blink.B1);
		#ifdef debugLED
		printf("time to sleep %i\n",blink.D1);
		#endif
		usleep(1000 * blink.D1);
		wigwagled(blink.R2,blink.G2,blink.B2);
		#ifdef debugLED
		printf("time to sleep %i\n",blink.D2);
		#endif
		usleep(1000 * blink.D2);
	}
	return NULL;
}

int daemonize(void){
	pid_t process_id = 0;
	pid_t sid = 0;
// Create child process
	process_id = fork();
// Indication of fork() failure
	if (process_id < 0)
	{
		printf("fork failed!\n");
// Return failure in exit status
		return 1;
	}
// PARENT PROCESS. Need to kill it.
	if (process_id > 0)
	{
		printf("process_id of child process %d \n", process_id);
// return success in exit status
		exit(0);
	}
//unmask the file mode
	umask(0);
//set new session
	sid = setsid();
	if(sid < 0)
	{
// Return failure
		return 1;
	}
// Change the current working directory to root.
	chdir("/");
// Close stdin. stdout and stderr
	close(STDIN_FILENO);
	close(STDOUT_FILENO);
	close(STDERR_FILENO);
	sleep(1);
	return 0;
}
int main (int argc, char *argv[]) {
	printf("ok did you overide\n");
	char *logfilename = "/wigwag/log/leddaemon.log";
	sleep(1);
	if (daemonize()){
		printf("failed to daemonize \n");
		exit(1);
	}
	logfile = fopen(logfilename, "w");
	if (logfile == NULL) {
		fprintf(stderr, "Can't open log file %s\n", logfilename);
		return 1;
	}
	init_LED();
	wigwagled(0,0,0);
	while(1){
		init_socket();
	}
	fclose(logfile);
	return (0);
}
