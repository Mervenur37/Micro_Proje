Smart Home HVAC Control System (Akıllı Ev İklimlendirme Kontrolü)
Bu proje, PIC16F877A mikrodenetleyicisi ve Assembly dili kullanılarak geliştirilmiş bir akıllı ev klima ve fan kontrol sistemidir. Sistem, ADC üzerinden ortam sıcaklığını okuyarak ısıtma/soğutma kararını verir, fan hızını ölçer ve UART üzerinden dış dünya ile haberleşir.

Features & Technical Details (Özellikler ve Teknik Detaylar)
Sıcaklık Ölçümü ve Kontrolü: RA0 pini üzerindeki ADC modülü kullanılarak analog sıcaklık verisi (örn. LM35) okunduktan sonra dijitale çevrilir. Hedef sıcaklık 10°C ile 50°C arasında sınırlandırılmış olup, sistem okunan değere göre soğutma veya ısıtma ünitelerini yönetir.

Fan Hızı Ölçümü: RA4 pini üzerinden TMR0 (Timer0) modülü sayılarak fanın gerçek zamanlı dönüş hızı hesaplanır.

Ekran Yönetimi: Ekranın (LCD) güncellenmesi ve yenilenme periyotları TMR1 (Timer1) kullanılarak kontrol edilir.

UART (Seri Haberleşme): Sistem, dışarıdan komut almak veya veri göndermek için seri haberleşme kullanır. Örneğin:

0x01 komutu ile hedeflenen düşük sıcaklık (Get Desired Low) değeri okunur.

0x05 komutu ile güncel fan hızı (Get Fan Speed) sisteme çekilir.

Technologies Used (Kullanılan Teknolojiler)
Microcontroller: PIC16F877A

Programming Language: Assembly

Architecture: 8-bit Microcontroller Architecture

Key Modules: ADC, TMR0, TMR1, UART

├── src/                # Assembly kaynak kodları (.asm)
├── build/              # Derlenmiş .hex dosyası
├── schematics/         # Proteus simülasyon dosyası (.pdsprj)
└── README.md           # Proje dokümantasyonu

Getting Started (Nasıl Çalıştırılır?)
Kaynak kodları (.asm) MPLAB IDE kullanarak derleyin.

Elde edilen .hex dosyasını PIC programlayıcı (PICkit vb.) aracılığıyla PIC16F877A'ya yükleyin. (Simülasyon için Proteus üzerinden mikrokontrolcüye .hex dosyasını verebilirsiniz.)

Donanım bağlantılarını yaparken RA0 pinine sıcaklık sensörünü ve UART pinlerine (TX/RX) seri haberleşme arabirimini bağladığınızdan emin olun.

UART üzerinden uygun Hex komutlarını (örn: 0x05) göndererek sistemin tepkilerini test edebilirsiniz.
