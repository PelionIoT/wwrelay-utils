#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

//#define SOCK_PATH "\0led"
char *socket_path="\0led";

void strip(char *s) {
    char *p2 = s;
    while(*s != '\0') {
        if(*s != '\t' && *s != '\n') {
            *p2++ = *s++;
        } else {
            ++s;
        }
    }
    *p2 = '\0';
}

int externalconnect(void){
    //char *socket_path="\0led";
    int s, t, len;
    struct sockaddr_un remote;
    char str[100];

    if ((s = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
        perror("socket");
        exit(1);
    }

    printf("Trying to connect...\n");

    remote.sun_family = AF_UNIX;
   //strcpy(remote.sun_path, SOCK_PATH);

    if (*socket_path == '\0') {
        memset(remote.sun_path, '\0', sizeof(remote.sun_path));
        *remote.sun_path = '\0';
        strncpy(remote.sun_path+1, socket_path+1, sizeof(remote.sun_path)-2);
    } else {
        strncpy(remote.sun_path, socket_path, sizeof(remote.sun_path)-1);
    }
    //strcpy(remote.sun_path, socket_path);

    len = strlen(remote.sun_path) + sizeof(remote.sun_family);
    printf("mylen %i\n",sizeof(remote));
    //if (connect(s, (struct sockaddr *)&remote, len) == -1) {
    if (connect(s, (struct sockaddr *)&remote, sizeof(remote)) == -1) {
        perror("connect");
        exit(1);
    }

    printf("Connected.\n");

    while(printf("> "), fgets(str, 100, stdin), !feof(stdin)) {
        strip(str);
        if (send(s, str, strlen(str), 0) == -1) {
            perror("send");
            exit(1);
        }

        if ((t=recv(s, str, 100, 0)) > 0) {
            str[t] = '\0';
            printf("echo> %s", str);
        } else {
            if (t < 0) perror("recv");
            else printf("Server closed connection\n");
            exit(1);
        }
    }
    close(s);
}


int main(void)
{
#if 1
   externalconnect();
 #else
    int s, t, len;
    struct sockaddr_un remote;
    char str[100];

    if ((s = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
        perror("socket");
        exit(1);
    }

    printf("Trying to connect...\n");

    remote.sun_family = AF_UNIX;
   //strcpy(remote.sun_path, SOCK_PATH);

    if (*socket_path == '\0') {
        *remote.sun_path = '\0';
        strncpy(remote.sun_path+1, socket_path+1, sizeof(remote.sun_path)-2);
    } else {
        strncpy(remote.sun_path, socket_path, sizeof(remote.sun_path)-1);
    }
    //strcpy(remote.sun_path, socket_path);

    len = strlen(remote.sun_path) + sizeof(remote.sun_family);
    printf("mylen %i\n",sizeof(remote));
    //if (connect(s, (struct sockaddr *)&remote, len) == -1) {
    if (connect(s, (struct sockaddr *)&remote, sizeof(remote)) == -1) {
        perror("connect");
        exit(1);
    }

    printf("Connected.\n");

    while(printf("> "), fgets(str, 100, stdin), !feof(stdin)) {
        strip(str);
        if (send(s, str, strlen(str), 0) == -1) {
            perror("send");
            exit(1);
        }

        if ((t=recv(s, str, 100, 0)) > 0) {
            str[t] = '\0';
            printf("echo> %s", str);
        } else {
            if (t < 0) perror("recv");
            else printf("Server closed connection\n");
            exit(1);
        }
    }
    close(s);
    #endif

   return 0;
}