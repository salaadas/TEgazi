[Dip ]
>Dip is a fine and challenging
>computer opponent. If you have
>played before, select it.
EDITABLE 0
PATIENT 1
NOISY 0
KEYDOWN STEP
INITSPEED 0.1
SKYLIMIT 4
SKYPUNISH -100
HOLEPUNISH -10
; sky:left:right:down:top
BONUSES 2:24:24:48:12
; left:right:down:top
BLOCKBONUS 0:0:0:0
AUTHOR Bisqwit


[Dat ]
>Dat is conservative,
>but not effective.
>
EDITABLE 0
PATIENT 1
NOISY 1
KEYDOWN STEP
INITSPEED 0.1
SKYLIMIT 0
SKYPUNISH -25
HOLEPUNISH 0
; sky:left:right:down:top
BONUSES 1:0:0:60:0
; left:right:down:top
BLOCKBONUS 0:0:10:0
AUTHOR Bisqwit


[Sim ]
>Sim is a simple tetris bot design
>simulation which uncutely tries to
>get the blocks as low as possible.
EDITABLE 0
PATIENT 0
NOISY 1
KEYDOWN STEP
INITSPEED 0.1
SKYLIMIT 0
SKYPUNISH -500
HOLEPUNISH 0
BONUSES 1:0:0:24:0
BLOCKBONUS 0:0:0:0
AUTHOR Bisqwit


[Blip]
>Blip plays beautifully, is sporty
>and interesting, but not the quite
>most potential winner.
EDITABLE 0
PATIENT 1
NOISY 0
KEYDOWN STEP
INITSPEED 0.2
SKYLIMIT 5
SKYPUNISH -400
HOLEPUNISH -20
BONUSES 2:120:120:12:120
BLOCKBONUS 0:0:0:10
AUTHOR Bisqwit

           X
    XXX   XXz
    zzX   XXz
    z X   Xzz
    z X   XXXX
    XXX
    
 3 <- 1d  2d -> 6
60 <- 2u  3r -> 90
30 <- 1r
    
    93    96

[Dak ]
>Dak is a demonstration of how one
>should not play tetris. Dak does
>everything with reverse logic...
EDITABLE 0
PATIENT 0
NOISY 0
KEYDOWN STEP
INITSPEED 0.1
SKYLIMIT 8
SKYPUNISH -1500
HOLEPUNISH -40
BONUSES 70:-12:-12:-74:1200
BLOCKBONUS 0:0:0:0
AUTHOR Bisqwit
