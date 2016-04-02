*=$0300
      lda #$06
      sta *$01
      tay
      lda #$10
      sta *$02
      lda #$03
      sta *$03
loop  lda *$01
      sta ($02),y
      dey
      cpy #$00
      bne loop