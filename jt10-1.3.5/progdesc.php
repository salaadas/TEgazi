<?php
//TITLE=Joeltris 10 and the series

$title = 'The saga of the Joeltris series';
$progname = 'jt10';

$text = array(
   '1. Purpose' => "

All of these games are some kind of tetris clones.
They have been written in chronological order.<p>
Author: <a href=\"http://iki.fi/bisqwit/\">Joel Yliluoma</a>

", '1. Joeltris 10' => "

  <ul>
   <li>Current version: 1.3.5
   <li>Writing started in April 1999.
   <li>Written in C. It has been tested in Linux, Solaris and HP-UX, but
       may work also in other unix systems as well.
   <li>Free software and under General Public License (GPL).
   <li>Implements the great and userfriendly NES-like interface.
   <li>Great sounds and symphonies ;-)
   <li>Year 2000 compatible and stable.
   <li>Very easy to use.
   <li>Computer opponents, especially Dip, are quite
       intelligent and still human-like players.
  </ul>
  
  Screenshots of the terminal version (vt100):<br>
  <a href=\"/src/joeltris10a.png\"><img src=\"/src/joeltris10a_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10b.png\"><img src=\"/src/joeltris10b_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10c.png\"><img src=\"/src/joeltris10c_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10d.png\"><img src=\"/src/joeltris10d_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10e.png\"><img src=\"/src/joeltris10e_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <br>
  Screenshots of the GUI version (SDL):<br>
  <a href=\"/src/joeltris10A.png\"><img src=\"/src/joeltris10A_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10B.png\"><img src=\"/src/joeltris10B_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10C.png\"><img src=\"/src/joeltris10C_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10D.png\"><img src=\"/src/joeltris10D_th.png\" alt=\"Joeltris 10 / vt100\"></a>
  <a href=\"/src/joeltris10E.png\"><img src=\"/src/joeltris10E_th.png\" alt=\"Joeltris 10 / vt100\"></a>

", '1.1. Requirements' => "

    <ul>
     <li><a href=\"http://www.linux.org\">Linux</a> system, perhaps 2.0.36 or newer, or some other unix system.
     <li>Keyboard or other input device, preferably vt100-compatible.
     <li>Monitor, screen or other output device, preferably also vt100-compatible.
     <li>Sound card is highly recommended. At least 200W basso boost mininum
         and as big diameter of the loudspeakers as possible. However, if your
         system has only a tiny speaker that's not bigger than a handwatch
         bell, it's ok.
     <li>libggi supported - can use svgalib, X and Linux framebuffer devices at least.
     <li>SDL supported now too.
     <li>Tested in Linux console, Solaris X terminal and KDE window.
    </ul>

", '1.1. History' => "

    <ul>
     <li>In 1991, Vadim Gerasimov, Ed Logg, Kris Moser and Brad Fuller
         made a very simple and very good tetris game for NES.<br>
         They called it \"1991 NEW VERSION\". In some multiple games
         archive it was titled as \"Tetris 2\".
     <li>In 1991-1999, I have played it.
     <li>In April 1999 I decided to port the game to
         Linux, although I had no source codes.
     <li>In May 1999 - <em>Joeltris 10</em> was born.
     <li>In June 1999 - added Linux framebuffer driver
         to the game. Had cool transparency and antialias
         effects, great graphics etc...
     <li>In June 1999 - catastroph happened:
         Framebuffer driver sourcecode was accidentally
         destroyed forever: I tried hacking ext2fs, I tried
         to find backups from <a href=\"http://iki.fi/warp/\">Warp</a> (beta tester),
         I tried everything. Gave up.
     <li>In July-October 1999, slowly did some
         improvements to the game.
     <li>In October 1999 I published the game.
     <li>Laterly in Octover 1999 I added libggi support. It's great :)
     <li>In February 2000 the configure was updated...
     <li>In January 2008, added SDL support...
    </ul>

", '1.1. To be done, enhance list' => "

    <ul>
     <li>Evil blocks and cheat blocks.
         (The game would give the player either the worst
         or the best possible blocks in varying cases.
         Currently all these games (except Joeltris 9)
         give all the blocks randomly.)
     <li>TCP/IP support. Maybe two, maybe more simultaneous
         players either cooperatively or as opponents.
     <li>High score lists.<br>
         Isn't so hard to do that, but the file sharing issue delays me.
    </ul>

", '1. Joeltris 1-6' => "

  <ul>
   <li>All written between Aug 30 1993 - Mar 4 1994.
   <li>Written in QBasic.
   <li>Joeltris 4 was written in Dec 17 1993 (I was 15 years old) with
       <a href=\"http://bisq.stc.cx/hardware.html#tandy\">Tandy 1000</a>
       (cga-compatible and equipped with 8088 processor).
   <li>Joeltrises 1-3 have been written using a 286 computer.
    <ul>
     <li>Thanks to Jorma Jääskeläinen, his parents, his little brother Vesa and the friends of his little brother.
     <li>Thanks also to <a href=\"http://www.hut.fi/~jjkarppi/\">Jouni Karppinen</a>.
    </ul>
   <li>Joeltris 3 and 6 require a VGA display with 16 colours support.
   <li>Joeltris 3 should be pentis or something: It uses only blocks with 5 pieces. Difficult.
   <li>The graphics of Joeltris 3 were inspired by Fire and Ice, aka. Solomon's Key 2.
   <li>Joeltris 5 was never finished. It requires a missing blockset.1 file and its control is unfinished anyway.
   <li>Joeltris 6 uses imaginary blocks with a lot different sizes. Very brain shocking.
   <li>Joeltrises 4-5 have been written somewhere. I don't have much memories of writing them.
       Possible I wrote them with <a href=\"http://www.topisoft.fi\">Topi Maurola</a>'s computer.
   <li>Joeltrises 1, 2 and 4 are the only games from the whole set having high score lists.
   <li>Joeltris 4 is the only game from the whole set having block
       with a special meaning. In Joeltris 4 the brown blocks negate
       everything below when pressed enter.
   <li>Joeltris 6 was the first of the games to generate its blocks
       itself instead of having lots of data defining the blocks
       and the ways of rotating them.
  </ul>
  
  <a href=\"/src/joeltris.png\"><img src=\"/src/joeltris_th.png\" alt=\"Joeltris, the original\"></a>
  <a href=\"/src/joeltris2.png\"><img src=\"/src/joeltris2_th.png\" alt=\"Joeltris 2\"></a>
  <a href=\"/src/joeltris3.png\"><img src=\"/src/joeltris3_th.png\" alt=\"Joeltris 3\"></a>
<!--  <a href=\"/src/joeltris3b.png\"><img src=\"/src/joeltris3b_th.png\" alt=\"Joeltris 3, highscore list\"></a>-->
  <a href=\"/src/joeltris4.png\"><img src=\"/src/joeltris4_th.png\" alt=\"Joeltris 4\"></a>
  <a href=\"/src/joeltris5.png\"><img src=\"/src/joeltris5_th.png\" alt=\"Joeltris 5\"></a>
  <a href=\"/src/joeltris6.png\"><img src=\"/src/joeltris6_th.png\" alt=\"Joeltris 6\"></a>

", '1.6. Requirements' => "

    <ul>
     <li>A pc computer with MS-DOS and QBasic.
     <li>Speed requirements vary.
     <li>Keyboard and monitor are helpful.
    </ul>

", '1. Joeltris 7' => "

  <ul>
   <li>My friend had a modem. He had also a BBS.
   <li>Then I was making a tetris game for the bbs.
   <li>This is the result. It may work, and it may not work.
   <li>Supporting simultaneous chat and game.
   <li>Written in 1995-1996.
  </ul>

  <a href=\"/src/joeltris7.png\"><img src=\"/src/joeltris7_th.png\" alt=\"Joeltris 7\"></a>

", '1.7. Requirements' => "

    <ul>
     <li>A pc computer with MS-DOS.
     <li>Compiles with Turbo Pascal. Requires <a href=\"/src/useful.pas\">useful.pas</a>
                                          and <a href=\"/src/usemotu.pas\">usemotu.pas</a>.
     <li>I am not sure which of a modem and a keyboard and a monitor are required.
    </ul>

", '1. Joeltris 8' => "

  <ul>
   <li>Definetely the most bugless of Joeltrises 1-9.
   <li>Supports one or two simultaneous players (keyboard).
   <li>Graphics. Requires a VGA display with 256 colours support.
   <li>Tiny and compact source code.
   <li>Written in school. (Keravan Ammattikoulu)
   <li>Theoretical computer player support. Not implemented.
   <li>Supports not only normal 4 piece blocks, but any sizes
       between 1..25. Get an outstanding experience of Tetris
       by playing with blocks with just one piece :-)
  </ul>

  <a href=\"/src/joeltris8.png\"><img src=\"/src/joeltris8_th.png\" alt=\"Joeltris 8\"></a>

", '1.8. Requirements' => "

    <ul>
     <li>A pc computer with MS-DOS and a VGA compatible display card.
     <li>Compiles with Turbo Pascal. Requires <a href=\"/src/mtask.pas\">mtask.pas</a>
                                          and <a href=\"/src/svga.pas\">svga.pas</a>.
     <li>A monitor and a keyboard.
    </ul>

", '1. Joeltris 9 and 9b' => "

  <ul>
   <li>The most complicated DOS tetris project I have had.
       Would be my most complicated DOS text mode game project
       also, if I didn't count DUD. More about DUD later in time.
   <li>Implements a <a href=\"/src/joeltris9-config.txt\">scripting language</a>
    <ul>
     <li>Different arrow keys translations done with the script
     <li>Score calculations done with the script
     <li>No block markers in the language (begin/end or { and }).<br>
         Logical blocks are detected by indentation levels. Great :)
     <li>ELSE is not supported.
     <li>Uses and implements various programmer-definable timers.
    </ul>
   <li>Configurable block removal names. Defaulting to
       SINGLE, DOUBLE, TRIPLE, TETRIS, PENTA and MIRACLE.
   <li>Supporting different sized blocks. 
       4 are 5 are quite playable, but at least 6 is supported too.
   <li><em>Evilblocks/cheatblocks support</em>.
    <ul>
     <li>Setting it 255 makes your game as easy as possible.
     <li>Setting it -255 gives you always the block you don't want.
     <li>If the game decides to give you some special block and you
         don't put it to the position it wants it to be in, it will
         give you the same block as many times as needed until you
         understand what it wants :)
     <li>Negative settings work fine, I have tested.
     <li>I am not so sure about the positive settings.
     <li>For a fair game, set it to zero - for both players.
    </ul>
   <li>Supports modem (fossil driver), meant primarily as a plugin to PC&nbsp;Board&nbsp;(PCB).
   <li>Supporting real time colour Julia fractal animation on background in text mode (in vt100)
   <li>With different back ground images (screenshots of development)
   <li>More incomplete than I thought: It does not yet support gameover.
   <li>This was the first Joeltris where I used my <em>own</em> computer
       in writing it! All the previous ones were written in the residences
       of my friends or in the school computer class. I just did not have
       a computer before.
  </ul>

  <a href=\"/src/joeltris9.png\"><img src=\"/src/joeltris9_th.png\" alt=\"Joeltris 9 gameplay\"></a>
  <a href=\"/src/joeltris9-config.txt\"><img src=\"/src/joeltris9-config_th.png\" alt=\"Joeltris 9 configuration\"></a>

", '1.9. Requirements' => "

    <ul>
     <li>A pc computer with MS-DOS.
     <li>Compiles with Turbo Pascal. Requires <a href=\"/src/timer.pas\">timer.pas</a>,
                                              <a href=\"/src/x00fossi.pas\">x00fossi.pas</a>
                                          and <a href=\"/src/ansiemu.pas\">ansiemu.pas</a>.
     <li>A monitor and a keyboard are optional.
    </ul>

", '1. Joeltris A (on idea level)' => "

   <ul>
    <li>Never released, never even played.
    <li>Supports tilting the blocks with not just 90, but any angle.
   </ul>

", '1. Joeltris B (on idea level)' => "

   <ul>
    <li>Not really a tetris game.
    <li>Based on the idea of the Wario's World game on the Nintendo Entertainment System (NES).
   </ul>

", '1. Copying' => "

The contents of these archives have been written by Joel Yliluoma, a.k.a.
<a href=\"http://iki.fi/bisqwit/\">Bisqwit</a>.
<p>
Joeltris 10 is free software, distributed under the terms of the
<a href=\"http://www.gnu.org/licenses/licenses.html#GPL\">General Public License</a> (GPL).
<p>
  The rest are considered as learnware.
  Free to use, free to modify etc. However, don't spoil my \"imago\" with
  them :) I have written them a long time ago.<br>
  If you want to help me in the Joeltris 10 project,
  <a href=\"http://bisqwit.iki.fi/#contact\">contact me</a>.

");
include '/WWW/progdesc.php';
