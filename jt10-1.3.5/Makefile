#!/usr/bin/make
#
# The Makefile (GNU compatible) for Joeltris 10 - unix version
ifneq (,)
This makefile requires GNU Make.
endif

VERSION=1.3.5

ARCHDIR=archives/
ARCHNAME=jt10-$(VERSION)
ARCHFILES=\
  COPYING ChangeLog FAQ INSTALL README TODO \
  Makefile.cfg Enkka.txt \
  audio.h \
  audio_aix.c audio_alsa.c audio_esd.c audio_hpux.c audio_irix.c \
  audio_mklinux.c audio_none.c audio_oss.c audio_ossmidi.c \
  audio_solaris.c audio_stderr.c audio_x86adlib.c \
  audiotest.c iotest.c \
  bin2c.c config.h config.sub1 config.sub2 config.sub3 configure \
  music.c music.h \
  music_cv1d.c music_cv2b.c music_teto.c music_tetr.c music_tett.c \
  music_mm31.c music_mm3p.c music_none.c music_sols.c music_tet1.c \
  music_tet4.c music_teta.c music_tetb.c music_tetk.c music_tetl.c \
  cons.h dialog.c findbest.c io.c io.h io_fb.c io_ggi.c io_sdl.c io_term.c \
  jt10.com main.c makemusa misc.c misc.h tetris.c tetris.h \
  jt10pali.pcx \
  jt1-6/joeltri2,bas jt1-6/joeltri2.bas jt1-6/joeltri3.bas jt1-6/joeltri4,bas \
  jt1-6/joeltri4.bas jt1-6/joeltri5,bas jt1-6/joeltri5.bas jt1-6/joeltri6,bas \
  jt1-6/joeltri6.bas jt1-6/joeltris.bas jt1-6/startup.com \
  jt7-9/blockset.1 jt7-9/bp.dsk jt7-9/bp.tp jt7-9/fielddat.jt3 jt7-9/hisc.dat \
  jt7-9/joeltr9b.cfg jt7-9/joeltr9b.pas jt7-9/joeltri3.pas jt7-9/joeltri7.pas \
  jt7-9/joeltri8.pas jt7-9/joeltri9.cfg jt7-9/joeltri9.pas jt7-9/joeltria.pas \
  jt7-9/joeltrib.pas jt7-9/jt9a.ans jt7-9/jt9b.ans jt7-9/jt9cfgnw.cfg \
  jt7-9/jt9fract.pas jt7-9/remx00.exe jt7-9/testi.ans jt7-9/tetrpali.pcx \
  jt7-9/x00.bat jt7-9/x00fossi.pas \
  makediff.php progdesc.php

BINDIR = /usr/games

PROG = joeltris10
LINKS = joeltris jt10
OBJS = main.o misc.o tetris.o music.o io.o jt10pali.o \
	music_cv1d.o music_tet1.o \
	music_cv2b.o music_tet4.o \
	music_tetk.o music_tetl.o \
	music_teta.o music_tetr.o \
	music_tetb.o music_tett.o \
	music_teto.o music_sols.o \
	music_none.o music_mm3p.o \
	io_term.o \
	io_ggi.o \
	io_sdl.o


#gruu: $(ARCHFILES) ;

all: $(PROG) iotest audiotest

include Makefile.cfg

DEFS := -DVERSION=\"$(VERSION)\"

# LDFLAGS include is here for possible -s and -pipe
CFLAGS := $(CFLAGS) $(DEFS) -g
# -ansi

###                                             ###
### BELOW THIS, USER SHOULD NOT CHANGE ANYTHING ###
###                                             ###

$(PROG): $(OBJS)
	$(CC) $(LDFLAGS) $(LDLIBS) -o $@ $(OBJS)
	for s in $(LINKS); do ln -sf $@ $$s;done

io.h: config.h
music.h: config.h
iotest: iotest.o io.o misc.o io_term.o io_ggi.o io_sdl.o jt10pali.o
audiotest: audiotest.o music.o music_mm31.o
dialog: dialog.o io.o io_term.o misc.o

# "config.h" is created by "configure".
#config.h:

music_cv1d.o: music_cv1d.c
music_cv1d.h: makemusa
	./makemusa h $*

music_cv2b.o: music_cv2b.c
music_cv2b.h: makemusa
	./makemusa h $*

music_tet1.o: music_tet1.c
music_tet1.h: makemusa
	./makemusa h $*

music_tet4.o: music_tet4.c
music_tet4.h: makemusa
	./makemusa h $*

music_tetk.o: music_tetk.c
music_tetk.h: makemusa
	./makemusa h $*

music_tett.o: music_tett.c
music_tett.h: makemusa
	./makemusa h $*

music_tetl.o: music_tetl.c
music_tetl.h: makemusa
	./makemusa h $*

music_tetb.o: music_tetb.c
music_tetb.h: makemusa
	./makemusa h $*

music_teta.o: music_teta.c
music_teta.h: makemusa
	./makemusa h $*

music_tetr.o: music_tetr.c
music_tetr.h: makemusa
	./makemusa h $*

music_teto.o: music_teto.c
music_teto.h: makemusa
	./makemusa h $*

music_sols.o: music_sols.c
music_sols.h: makemusa
	./makemusa h $*

music_mm3p.o: music_mm3p.c
music_mm3p.h: makemusa
	./makemusa h $*

music_mm31.o: music_mm31.c
music_mm31.h: makemusa
	./makemusa h $*

music_none.o: music_none.c
music_none.h: makemusa
	./makemusa h $*

./bin2c: bin2c.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $<
jt10pali.o: jt10pali.c
jt10pali.c: jt10pali.pcx ./bin2c
	./bin2c jt10pali.pcx jt10pali jt10pali
	
Makefile.cfg: configure
	@echo
	@echo You need to run configure first.
	@echo
	@false

INSTALLPROGS=$(PROG)
DEPFUN_INSTALL=tetris
include depfun.mak
	
install: installtetris
	for s in $(LINKS); do ln -sf $(PROG) $(BINDIR)/$$s; done

# Clean everything remakable.
clean:
	rm -f $(PROG) iotest audiotest *.o
	rm -f $(OBJS) music_*.h
	rm -f jt10pali.c ./bin2c $(LINKS)
	
# Clean everything that do
# not need to be shipped.
distclean: clean
	rm -f core config.h *~
	rm -f music_*.h intgen findbest findbest.c
	rm -f tmptmp Makefile.cfg *.s
	
# Clean also things which can't be rebuilt
# without Oktober-define and are needed to
# build the game. Don't use!
realclean: distclean
	rm -f music_*.c jt10pali.pcx


.PHONY: install clean distclean realclean
