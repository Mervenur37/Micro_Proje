
; Proje: AKILLI EV - BOARD 2 (PERDE & SENSOR)

;***************************************
 
;Metin Mert Ceylan 151220222052  
;Mehmet Türk 152120221057  

;***************************************
    LIST    P=16F877A
    INCLUDE "P16F877A.INC"

    __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF & _CP_OFF


CBLOCK 0x20
    
    ldr_veri        
    yuzde           
    sonuc_ldr       
    sonuc_pot       
    
   
    hedef_konum     
    pot_son         
    fark            
    pc_modu         
    
    
    gelen_veri      
    gecici          
    sayac           
    matematik_1     
    matematik_2
    
    
    sicaklik_tam
    sicaklik_onda
    basinc_tam
    basinc_dusuk
    bmp_yuksek
    bmp_dusuk
    i2c_veri
    ham_isi_H
    ham_isi_L
    
   
    adim_simdiki_L
    adim_simdiki_H
    adim_hedef_L
    adim_hedef_H
    motor_fazi
    
    
    lcd_temp
    basamak_bir
    basamak_on
    basamak_yuz
    bekleme1
    bekleme2
    lcd_sayaci
    
    
    w_temp
    status_temp
ENDC


ORG 0x000
    GOTO AYARLAR

;Interruptlar
ORG 0x004
    GOTO ISR_Handler

ISR_Handler:
    MOVWF w_temp            
    SWAPF STATUS, W         
    MOVWF status_temp       
    
    BCF STATUS, RP0
    BCF STATUS, RP1
    

    BTFSS PIR1, RCIF        
    GOTO ISR_Cikis          
    
    
    BTFSC RCSTA, OERR
    GOTO UART_Hata
    BTFSC RCSTA, FERR
    GOTO UART_Hata
    
    ; Veriyi Al ve Isle
    MOVF RCREG, W
    MOVWF gelen_veri
    CALL Komut_Isle
    GOTO ISR_Cikis

UART_Hata:
    BCF RCSTA, CREN         
    MOVF RCREG, W           
    BSF RCSTA, CREN         
    GOTO ISR_Cikis

ISR_Cikis:
    SWAPF status_temp, W    
    MOVWF STATUS
    SWAPF w_temp, F
    SWAPF w_temp, W         
    RETFIE


Komut_Isle:
    ; 1. PERDE AYARLA 
    MOVF gelen_veri, W
    ANDLW b'11000000'
    SUBLW b'11000000'
    BTFSC STATUS, Z
    GOTO Perde_Ayarla_PC
    
    ; 2. SORGULAR 
    MOVF gelen_veri, W
    XORLW 0x01
    BTFSC STATUS, Z
    GOTO Gonder_Perde_L
    
    MOVF gelen_veri, W
    XORLW 0x02
    BTFSC STATUS, Z
    GOTO Gonder_Perde_H
    
    MOVF gelen_veri, W
    XORLW 0x03
    BTFSC STATUS, Z
    GOTO Gonder_Temp_L
    
    MOVF gelen_veri, W
    XORLW 0x04
    BTFSC STATUS, Z
    GOTO Gonder_Temp_H
    
    MOVF gelen_veri, W
    XORLW 0x05
    BTFSC STATUS, Z
    GOTO Gonder_Basinc_L
    
    MOVF gelen_veri, W
    XORLW 0x06
    BTFSC STATUS, Z
    GOTO Gonder_Basinc_H
    
    MOVF gelen_veri, W
    XORLW 0x08
    BTFSC STATUS, Z
    GOTO Gonder_Isik
    
    RETURN

Perde_Ayarla_PC:
    MOVF gelen_veri, W
    ANDLW b'00111111'       
    MOVWF hedef_konum
    BSF pc_modu, 0          
    RETURN


Gonder_Perde_L:  MOVLW d'0' 
                 GOTO Veri_Gonder
Gonder_Perde_H:  MOVF hedef_konum, W 
                 GOTO Veri_Gonder
Gonder_Temp_L:   MOVF sicaklik_onda, W 
                 GOTO Veri_Gonder
Gonder_Temp_H:   MOVF sicaklik_tam, W 
                 GOTO Veri_Gonder
Gonder_Basinc_L: MOVF basinc_dusuk, W 
                 GOTO Veri_Gonder
Gonder_Basinc_H: MOVF basinc_tam, W 
                 GOTO Veri_Gonder
Gonder_Isik:     MOVF sonuc_ldr, W 
                 GOTO Veri_Gonder

Veri_Gonder:
    MOVWF gecici
    
    BSF STATUS, RP0
Wait_TX:
    BTFSS TXSTA, TRMT       
    GOTO Wait_TX
    BCF STATUS, RP0         
    MOVF gecici, W
    MOVWF TXREG             
    RETURN

; Ayarlar
AYARLAR:
    BSF STATUS, RP0         
    MOVLW 0xFF
    MOVWF TRISA             
    CLRF TRISB              
    CLRF TRISD              
    
    
    BSF TRISC, 3
    BSF TRISC, 4
    BSF TRISC, 7            
    BCF TRISC, 6            
    
    MOVLW b'00000100'       
    MOVWF ADCON1
    
    
    MOVLW d'25'
    MOVWF SPBRG
    MOVLW b'00100100'       
    MOVWF TXSTA
    
    BSF PIE1, RCIE          
    
    BCF STATUS, RP0         
    MOVLW b'10010000'       
    MOVWF RCSTA
    MOVLW b'10000001'       
    MOVWF ADCON0
    
    BSF INTCON, PEIE        
    BSF INTCON, GIE         
    
    CLRF PORTB
    CLRF PORTD
    CLRF motor_fazi
    CLRF adim_simdiki_L
    CLRF adim_simdiki_H
    CLRF pc_modu
    CLRF pot_son
    
    MOVLW d'255'
    MOVWF lcd_sayaci
    
    CALL Gecikme_Uzun
    CALL LCD_Hazirla
    CALL LCD_Temizle
    CALL I2C_Kurulum
    CALL Gecikme_Kisa
    CALL Sensor_Oku         
    CALL Ekrana_Yaz


BASLA:
    
    MOVLW 0
    CALL ADC_Oku
    MOVWF ldr_veri
    CALL Yuzde_Hesapla
    MOVF yuzde, W
    MOVWF sonuc_ldr
    
    
    MOVLW d'50'
    SUBWF sonuc_ldr, W
    BTFSS STATUS, C         
    GOTO GECE_MODU          
    
    
    MOVLW 1
    CALL ADC_Oku
    MOVWF ldr_veri
    CALL Yuzde_Hesapla
    
    
    MOVF yuzde, W
    SUBLW d'100'
    MOVWF sonuc_pot
    
    
    MOVF sonuc_pot, W
    SUBWF pot_son, W
    MOVWF fark
    
    
    BTFSS fark, 7
    GOTO Fark_Pozitif
    COMF fark, F
    INCF fark, F
Fark_Pozitif:
    MOVLW d'3'              
    SUBWF fark, W
    BTFSS STATUS, C         
    GOTO Hareket_Yok        
    
    
    BCF pc_modu, 0
    
    ; Yeni degeri kaydet
    MOVF sonuc_pot, W
    MOVWF pot_son

Hareket_Yok:
    
    BTFSC pc_modu, 0        
    GOTO SENSOR_ISLEMLERI   
    
    
    MOVF sonuc_pot, W
    MOVWF hedef_konum
    GOTO SENSOR_ISLEMLERI

GECE_MODU:
    MOVLW d'100'
    MOVWF hedef_konum

SENSOR_ISLEMLERI:
    CALL Sensor_Oku         
    CALL Adim_Hesapla       
    CALL Motoru_Hareket_Ettir 
    
    
    DECFSZ lcd_sayaci, F
    GOTO BASLA
    
    CALL Ekrana_Yaz
    MOVLW d'50'
    MOVWF lcd_sayaci
    GOTO BASLA


Adim_Hesapla:
    CLRF adim_hedef_H
    CLRF adim_hedef_L
    MOVF hedef_konum,W
    MOVWF sayac
    MOVF sayac,F
    BTFSC STATUS,Z
    RETURN
Carpma_Dongusu:
    MOVLW d'10'
    ADDWF adim_hedef_L,F
    BTFSC STATUS,C
    INCF adim_hedef_H,F
    DECFSZ sayac,F
    GOTO Carpma_Dongusu
    RETURN

Motoru_Hareket_Ettir:
    MOVF adim_hedef_H,W
    SUBWF adim_simdiki_H,W
    BTFSS STATUS,Z
    GOTO Farkli_Byte
    MOVF adim_hedef_L,W
    SUBWF adim_simdiki_L,W
    BTFSC STATUS,Z
    RETURN
    BTFSC STATUS,C
    GOTO Geri_Git
    GOTO Ileri_Git
Farkli_Byte:
    BTFSC STATUS,C
    GOTO Geri_Git
    GOTO Ileri_Git
Ileri_Git:
    INCF adim_simdiki_L,F
    BTFSC STATUS,Z
    INCF adim_simdiki_H,F
    INCF motor_fazi,F
    MOVLW d'4'
    SUBWF motor_fazi,W
    BTFSC STATUS,Z
    CLRF motor_fazi
    CALL Fazi_Uygula
    RETURN
Geri_Git:
    MOVLW 1
    SUBWF adim_simdiki_L,F
    BTFSS STATUS,C
    DECF adim_simdiki_H,F
    DECF motor_fazi,F
    MOVLW 0xFF
    SUBWF motor_fazi,W
    BTFSC STATUS,Z
    GOTO Faz_3_Yap
    GOTO Fazi_Uygula
Faz_3_Yap:
    MOVLW d'3'
    MOVWF motor_fazi
    CALL Fazi_Uygula
    RETURN
Fazi_Uygula:
    MOVF motor_fazi,W
    CALL Faz_Tablosu
    MOVWF PORTD
    CALL Gecikme_Motor
    RETURN
Faz_Tablosu:
    ADDWF PCL,F
    RETLW b'00000001'
    RETLW b'00000010'
    RETLW b'00000100'
    RETLW b'00001000'
Gecikme_Motor:
    MOVLW d'10'
    MOVWF bekleme2
Dly_Loop:
    MOVLW d'100'
    MOVWF bekleme1
Ic_Loop:
    NOP
    DECFSZ bekleme1,F
    GOTO Ic_Loop
    DECFSZ bekleme2,F
    GOTO Dly_Loop
    RETURN

; ADC
Yuzde_Hesapla:
    MOVF ldr_veri,W
    MOVWF sayac
    CLRF matematik_1
    CLRF matematik_2
    MOVF sayac,F
    BTFSC STATUS,Z
    GOTO Yuzde_100_Yap
Hesap_Don:
    MOVLW d'101'
    ADDWF matematik_1,F
    BTFSC STATUS,C
    INCF matematik_2,F
    DECFSZ sayac,F
    GOTO Hesap_Don
    MOVF matematik_2,W
    SUBLW d'100'
    MOVWF yuzde
    RETURN
Yuzde_100_Yap:
    MOVLW d'100'
    MOVWF yuzde
    RETURN

ADC_Oku:
    ANDLW 0x07
    MOVWF lcd_temp
    BCF ADCON0,3
    BCF ADCON0,4
    BCF ADCON0,5
    BTFSC lcd_temp,0
    BSF ADCON0,3
    BTFSC lcd_temp,1
    BSF ADCON0,4
    BTFSC lcd_temp,2
    BSF ADCON0,5
    BSF ADCON0,ADON
    CALL Gecikme_Kisa
    BSF ADCON0,GO
Wait_ADC:
    BTFSC ADCON0,GO
    GOTO Wait_ADC
    MOVF ADRESH,W
    RETURN

;I2C
I2C_Kurulum:
    BSF STATUS, RP0
    BSF TRISC, 3
    BSF TRISC, 4
    MOVLW d'9'
    MOVWF SSPADD
    BCF STATUS, RP0
    MOVLW b'00101000'
    MOVWF SSPCON
    RETURN
I2C_Basla:
    BSF STATUS, RP0
    BSF SSPCON2, SEN
    BCF STATUS, RP0
I2C_Basla_Bekle:
    BSF STATUS, RP0
    BTFSC SSPCON2, SEN
    GOTO I2C_Basla_Bekle
    BCF STATUS, RP0
    RETURN
I2C_Dur:
    BSF STATUS, RP0
    BSF SSPCON2, PEN
    BCF STATUS, RP0
I2C_Dur_Bekle:
    BSF STATUS, RP0
    BTFSC SSPCON2, PEN
    GOTO I2C_Dur_Bekle
    BCF STATUS, RP0
    RETURN
I2C_Yeniden_Basla:
    BSF STATUS, RP0
    BSF SSPCON2, RSEN
    BCF STATUS, RP0
I2C_Yeniden_Bekle:
    BSF STATUS, RP0
    BTFSC SSPCON2, RSEN
    GOTO I2C_Yeniden_Bekle
    BCF STATUS, RP0
    RETURN
I2C_Yaz:
    MOVWF SSPBUF
I2C_Yaz_Bekle:
    BTFSS PIR1, SSPIF
    GOTO I2C_Yaz_Bekle
    BCF PIR1, SSPIF
    BSF STATUS, RP0
    BTFSC SSPCON2, ACKSTAT
    BCF STATUS, Z
    BTFSS SSPCON2, ACKSTAT
    BSF STATUS, Z
    BCF STATUS, RP0
    RETURN
I2C_Oku:
    BSF STATUS, RP0
    BSF SSPCON2, RCEN
    BCF STATUS, RP0
I2C_Oku_Bekle:
    BSF STATUS, RP0
    BTFSC SSPCON2, RCEN
    GOTO I2C_Oku_Bekle
    BCF STATUS, RP0
    BTFSS PIR1, SSPIF
    GOTO I2C_Oku_Bekle
    BCF PIR1, SSPIF
    MOVF SSPBUF, W
    MOVWF i2c_veri
    RETURN
I2C_Onay_Ver:
    BSF STATUS, RP0
    BCF SSPCON2, ACKDT
    BSF SSPCON2, ACKEN
    BCF STATUS, RP0
I2C_Onay_Bekle:
    BSF STATUS, RP0
    BTFSC SSPCON2, ACKEN
    GOTO I2C_Onay_Bekle
    BCF STATUS, RP0
    RETURN
I2C_Onay_Verme:
    BSF STATUS, RP0
    BSF SSPCON2, ACKDT
    BSF SSPCON2, ACKEN
    BCF STATUS, RP0
I2C_Onay_Verme_Bekle:
    BSF STATUS, RP0
    BTFSC SSPCON2, ACKEN
    GOTO I2C_Onay_Verme_Bekle
    BCF STATUS, RP0
    RETURN


Sensor_Oku:
    CALL Sicaklik_Oku
    CALL Gecikme_Kisa
    CALL Basinc_Oku
    RETURN
Sicaklik_Oku:
    CALL I2C_Basla
    MOVLW 0xEE
    CALL I2C_Yaz
    MOVLW 0xF4
    CALL I2C_Yaz
    MOVLW 0x2E
    CALL I2C_Yaz
    CALL I2C_Dur
    CALL Gecikme_Kisa
    CALL I2C_Basla
    MOVLW 0xEE
    CALL I2C_Yaz
    MOVLW 0xF6
    CALL I2C_Yaz
    CALL I2C_Yeniden_Basla
    MOVLW 0xEF
    CALL I2C_Yaz
    CALL I2C_Oku
    MOVF i2c_veri, W
    MOVWF bmp_yuksek
    CALL I2C_Onay_Ver
    CALL I2C_Oku
    MOVF i2c_veri, W
    MOVWF bmp_dusuk
    CALL I2C_Onay_Verme
    CALL I2C_Dur
    MOVF bmp_yuksek, W
    MOVWF sicaklik_tam
    RRF sicaklik_tam, F
    RRF sicaklik_tam, F
    RRF sicaklik_tam, F
    BCF sicaklik_tam, 7
    BCF sicaklik_tam, 6
    BCF sicaklik_tam, 5
    MOVF bmp_dusuk, W
    ANDLW 0x0F
    MOVWF sicaklik_onda
    MOVLW d'10'
    SUBWF sicaklik_onda, W
    BTFSC STATUS, C
    MOVLW d'9'
    BTFSC STATUS, C
    MOVWF sicaklik_onda
    RETURN
Basinc_Oku:
    CALL I2C_Basla
    MOVLW 0xEE
    CALL I2C_Yaz
    MOVLW 0xF4
    CALL I2C_Yaz
    MOVLW 0x34
    CALL I2C_Yaz
    CALL I2C_Dur
    CALL Gecikme_Kisa
    CALL Gecikme_Kisa
    CALL I2C_Basla
    MOVLW 0xEE
    CALL I2C_Yaz
    MOVLW 0xF6
    CALL I2C_Yaz
    CALL I2C_Yeniden_Basla
    MOVLW 0xEF
    CALL I2C_Yaz
    CALL I2C_Oku
    MOVF i2c_veri, W
    MOVWF bmp_yuksek
    CALL I2C_Onay_Ver
    CALL I2C_Oku
    MOVF i2c_veri, W
    MOVWF bmp_dusuk
    CALL I2C_Onay_Verme
    CALL I2C_Dur
    MOVF bmp_yuksek, W
    MOVWF basinc_tam
    BCF STATUS, C
    RLF basinc_tam, F
    RLF basinc_tam, F
    MOVLW d'225'
    ADDWF basinc_tam, F
    MOVLW d'0'
    MOVWF basinc_dusuk
    RETURN


Ekrana_Yaz:
    MOVLW 0x80
    CALL LCD_Komut
    MOVLW 'T'
    CALL LCD_Veri
    MOVLW ':'
    CALL LCD_Veri
    MOVF sicaklik_tam,W
    MOVWF yuzde
    CALL Sayi_Yaz
    MOVLW '.'
    CALL LCD_Veri
    MOVF sicaklik_onda,W
    ADDLW '0'
    CALL LCD_Veri
    MOVLW ' '
    CALL LCD_Veri
    MOVLW 'P'
    CALL LCD_Veri
    MOVLW ':'
    CALL LCD_Veri
    MOVF basinc_tam,W
    MOVWF yuzde
    CALL Sayi_Yaz
    MOVLW '3'
    CALL LCD_Veri
    MOVLW 0xC0
    CALL LCD_Komut
    MOVLW 'x'
    CALL LCD_Veri
    MOVLW 'l'
    CALL LCD_Veri
    MOVLW ':'
    CALL LCD_Veri
    MOVF sonuc_ldr,W
    MOVWF yuzde
    CALL Sayi_Yaz
    MOVLW '%'
    CALL LCD_Veri
    MOVLW ' '
    CALL LCD_Veri
    MOVLW 'x'
    CALL LCD_Veri
    MOVLW 'c'
    CALL LCD_Veri
    MOVLW ':'
    CALL LCD_Veri
    MOVF hedef_konum,W
    MOVWF yuzde
    CALL Sayi_Yaz
    MOVLW '%'
    CALL LCD_Veri
    RETURN
Sayi_Yaz:
    MOVLW d'100'
    SUBWF yuzde,W
    BTFSC STATUS,C
    GOTO Yuz_Var
    CLRF basamak_on
    MOVF yuzde,W
    MOVWF basamak_bir
    MOVLW '0'
    CALL LCD_Veri
Bolme_Islemi:
    MOVLW d'10'
    SUBWF basamak_bir,W
    BTFSS STATUS,C
    GOTO Rakamlari_Yaz
    MOVWF basamak_bir
    INCF basamak_on,F
    GOTO Bolme_Islemi
Rakamlari_Yaz:
    MOVF basamak_on,W
    ADDLW '0'
    CALL LCD_Veri
    MOVF basamak_bir,W
    ADDLW '0'
    CALL LCD_Veri
    RETURN
Yuz_Var:
    MOVLW '1'
    CALL LCD_Veri
    MOVLW '0'
    CALL LCD_Veri
    MOVLW '0'
    CALL LCD_Veri
    RETURN
LCD_Komut:
    MOVWF lcd_temp
    ANDLW 0xF0
    MOVWF PORTB
    BCF PORTB,1
    NOP
    BSF PORTB,2
    CALL Gecikme_Kisa
    BCF PORTB,2
    SWAPF lcd_temp,W
    ANDLW 0xF0
    MOVWF PORTB
    BCF PORTB,1
    NOP
    BSF PORTB,2
    CALL Gecikme_Kisa
    BCF PORTB,2
    RETURN
LCD_Veri:
    MOVWF lcd_temp
    ANDLW 0xF0
    MOVWF PORTB
    BSF PORTB,1
    NOP
    BSF PORTB,2
    CALL Gecikme_Kisa
    BCF PORTB,2
    SWAPF lcd_temp,W
    ANDLW 0xF0
    MOVWF PORTB
    BSF PORTB,1
    NOP
    BSF PORTB,2
    CALL Gecikme_Kisa
    BCF PORTB,2
    RETURN
LCD_Hazirla:
    MOVLW d'20'
    CALL Gecikme_Uzun
    MOVLW 0x30
    CALL LCD_Nibble
    CALL Gecikme_Kisa
    MOVLW 0x30
    CALL LCD_Nibble
    CALL Gecikme_Kisa
    MOVLW 0x20
    CALL LCD_Nibble
    CALL Gecikme_Kisa
    MOVLW 0x28
    CALL LCD_Komut
    MOVLW 0x0C
    CALL LCD_Komut
    MOVLW 0x06
    CALL LCD_Komut
    RETURN
LCD_Nibble:
    ANDLW 0xF0
    MOVWF PORTB
    BSF PORTB, 2
    NOP
    BCF PORTB, 2
    RETURN
LCD_Temizle:
    MOVLW 0x01
    CALL LCD_Komut
    CALL Gecikme_Uzun
    RETURN


Gecikme_Kisa:
    MOVLW d'50'
    MOVWF bekleme1
Kisa_Loop:
    DECFSZ bekleme1, F
    GOTO Kisa_Loop
    RETURN
Gecikme_Uzun:
    MOVLW d'255'
    MOVWF bekleme2
Uzun_Dis_Loop:
    MOVLW d'255'
    MOVWF bekleme1
Uzun_Ic_Loop:
    DECFSZ bekleme1, F
    GOTO Uzun_Ic_Loop
    DECFSZ bekleme2, F
    GOTO Uzun_Dis_Loop
    RETURN

    END