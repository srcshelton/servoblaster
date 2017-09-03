
CC	 ?= gcc
CPPFLAGS ?= -I/opt/vc/include
CFLAGS	 ?= -Wall -Wextra -g -O2
LDFLAGS	 ?= -L/opt/vc/lib
LIBS	 := -lm -lbcm_host

.PHONY: all install uninstall clean
all:	servod

servod:	servod.c mailbox.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)

servodebug: servodebug.c
	$(CC) $(CFLAGS) -o $@ $^

install: servod
	[ "`id -u`" = "0" ] || { echo "Must be run as root"; exit 1; }
	install -d -m 0755 -o root -g root /usr/local/sbin
	install -d -m 0755 -o root -g root /etc/init.d
	install -bCSv -m 0755 -o root -g root $< /usr/local/sbin/servod
	install -bCSv -m 0755 -o root -g root init.sysv /etc/init.d/servoblaster
	update-rc.d servoblaster defaults 92 08
	#/etc/init.d/servoblaster start

uninstall:
	[ "`id -u`" = "0" ] || { echo "Must be run as root"; exit 1; }
	[ -e /etc/init.d/servoblaster ] && /etc/init.d/servoblaster stop || :
	update-rc.d servoblaster remove
	rm -f /usr/local/sbin/servod
	rm -f /etc/init.d/servoblaster

clean:
	rm -f servod servodebug
