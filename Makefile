
.PHONY: all install uninstall clean
all:	servod

servod:	servod.c mailbox.c
	gcc -Wall -g -O2 -o servod servod.c mailbox.c -lm

servodebug: servodebug.c
	gcc -Wall -O2 -o servodebug servodebug.c

install: servod
	[ "`id -u`" = "0" ] || { echo "Must be run as root"; exit 1; }
	install -d -m 0755 -o root -g root /usr/local/sbin
	install -d -m 0755 -o root -g root /etc/init.d
	install -bCSv -m 0755 -o root -g root servod /usr/local/sbin/servod
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
