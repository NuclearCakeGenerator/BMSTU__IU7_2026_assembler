CC = gcc
CFLAGS = -std=c11 -O2 -Wall -Wextra
LDLIBS = -lm

all: app.exe

app.exe: main.c
	$(CC) $(CFLAGS) -o app.exe main.c $(LDLIBS)

clean:
	rm -f app.exe
