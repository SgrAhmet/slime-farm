# Slime Farm — Geliştirme Kaydı

Son güncelleme: 2026-11-26. Bu dosya, bir sonraki oturumda kaldığımız yerden devam
edebilmek için yapılan her şeyin özetidir. Kod kuralları için `CLAUDE.md`'ye bak.

## Oyunun şu anki hali (özet)

Top-down piksel art slime çiftliği. Oyuncu vakum silahıyla slimeları, elma, havuç ve
gemleri toplar; slimeları besler, gem alır, gemleri satıp parayla bahçeye kümes/tarla
kurar. Ana menüden 3 kayıt slotu, yatakta uyuyunca kayıt.

## Kontroller

| Tuş | İşlev |
|---|---|
| WASD / ok tuşları | 8 yönlü hareket (sprite 4 yöne bakar) |
| Mouse | Nişan (vakum kullanırken karakter mouse'a döner) |
| Sağ tık (basılı) | Vakum: koni içindekileri çeker |
| Sol tık | Seçili slotu fırlat (basılı tut = 0.3 sn'de bir) |
| 1-8 / tekerlek | Envanter slotu seç |
| E | Etkileşim (yatak = uyu+kaydet, arsa = satın al menüsü, toplayıcı = gemleri al) |
| B | Slime Kitabı (keşfedilen türlerin bilgileri) |
| F1 | Debug paneli (hız, zamanı durdur/+3 saat, para, ışınlanma, açlık, civciv büyüt, eşya ver, kaydet) |
| Esc | Menüde geri / satın alma penceresini kapat |

## Sistemler ve dosyalar

### Çekirdek
- `scripts/game.gd` — **Autoload `Game`**. Aktif slot, `play_time` (oyun saati; açlık ve
  gece-gündüz buna bağlı, kayıtla saklanır), kayıt okuma/yazma, `SAVE_VERSION`,
  `slot_status()` (EMPTY/OK/OLD), `delete_save()`, `DAY_LENGTH=180` (1 gün = 3 dk),
  `time_of_day()`, `clock_text()`.
- `scripts/farm.gd` (`scenes/main.tscn` kökü) — Dünyayı kurar, propları yerleştirir,
  etkileşim (E), ipucu yazısı, satın alma, ev giriş/çıkış geçişi (karartma), uyku/kayıt,
  kayıttan yükleme, para (satış makinesi sinyali).
- `scripts/world_gen.gd` — `WorldGen`: tek kesintisiz harita. Bölgeler: FARM (çitli çiftlik,
  hücre 0..47 x 0..29), FOREST (batı, gürültüyle bozulmuş elips), HIGHLANDS (ormanın
  kuzeyi), MOUNTAINS (çiftliğin doğusu, doğu çitinde kapı; kuzeyi karlı, içinde geçilmez
  kaya kümeleri, çevresi kaya duvarı tile 20), NONE (sık ağaç örtüsü, geçilmez tile 13). Yol koridoru `ROUTE`. Ulaşılamayan
  cepler flood-fill ile örtüye çevrilir. **Sabit tohumlu**; `plan_props()` içine yeni
  yerleşim eklerken hep SONA ekle (kayıttaki ağaç sırası bozulmasın).
- `scripts/debug_panel.gd` — `DebugPanel` (F1). Fare paneldeyken vakum ateşlemez
  (`DebugPanel.blocks_mouse()`). `Game.time_paused` zamanı dondurur.
- `scripts/day_night.gd` — `DayNight` (CanvasModulate). Renk eğrisi (cubic), ev içinde
  lamba tonuna karışır. HUD etkilenmez.

### Ekran ve ses
- `project.godot`: 320x180 taban, `viewport` + `integer` ölçek (değişmedi).
- **Tam ekran denemesi geri alındı** (2026-11-27): ölçek ayarı, F11, varsayılan tam ekran,
  menü sıkıştırma kullanıcıda menüleri bozdu; hepsi eski haline döndü. Bilinen: kümes
  menüsü 5 seçenekle 181 px (ekran 180), üstten 1 px taşıyor.
- `scripts/sfx.gd` — **Autoload `Sfx`**: `play(name)` konumsuz, `play_at(name, pos)` dünyada
  konumlu (300 px'te söner). Ses başına dB tablosu, aynı ses arası en az 0.06 sn, en fazla
  14 eşzamanlı. Tüm `BaseButton`'lara otomatik tıklama sesi bağlar. `loop_stream()` vakum
  uğultusu için döngülü kopya.
- Sesler `tools/generate_sounds.gd` ile koddan sentezlenir -> `assets/sfx/*.wav`
  (vacuum_loop/pop/shoot, slime_hop/eat/happy/transform, gem, coin, chicken, chick,
  ui_click, save_jingle). Kullanıcı beğendi; vacuum_loop kısıldı (LOOP_PEAK 0.22, -10 dB).

### Oyuncu
- `scripts/player.gd` + `scenes/player.tscn` — `Player`. `input_enabled` (geçişlerde ve
  menüde kapanır; **process_mode ile dondurma** — fizikten çıkarıp ışınlanma sonrası
  eski konumda alan tetikliyor, sonsuz geçiş döngüsü bug'ı yaşandı). Yürüme animasyonu
  3 kare x 4 yön. `teleport()` interpolasyonu sıfırlar.
- `scripts/vacuum_gun.gd` — `VacuumGun`. Koni (30°, 70 px), görüş hattı (ray, mask 1),
  `item_launched(entry, at, velocity)` sinyali. Tık kenarı kendi takip edilir (çift atış bug'ı).
- `scripts/inventory.gd` — `Inventory`: 8 slot, slot başına tek tür, `ItemType.max_stack`,
  her adedin kendi verisi (`Entry{item, data}`; slime'ın `hungry_at`'ı), `money`,
  `to_dict()/from_dict()`.
- `scripts/inventory_hud.gd` — slotlar + sol üstte para (3x5 piksel rakamlar, 2x).

### Vakumlanabilir nesneler
- `scripts/vacuumable.gd` — `Vacuumable` (CharacterBody2D taban). Durumlar: GROUNDED /
  SUCKED (yavaş başlayıp hızlanan çekilme, ağza yaklaşınca küçülme) / LAUNCHED (yay
  uçuş, slimelara çarpınca geri sekip dibine düşer). `get_carry_data()/apply_carry_data()`.
  **Kümes duvarı katmanı `CORRAL_LAYER=16`**: dışarıdan fırlatılan uçarken duvarı yok
  sayar (içeri girer), kümesin İÇİNDEN fırlatılan duvara çarpar (`_is_inside_corral()`,
  "corrals" grubu). `corral_escape` = kalabalıkta kaçış.
- `scripts/slime.gd` + `scenes/slime.tscn` — `Slime`. Zıplayarak gezer, saldırmaz.
  Açken elma/havuç yer → mutlu → kendi gemi; 300 sn tok. Başka renkte gem görürse
  (aç/tok fark etmez) yer → **büyük slime'a dönüşür** (yanıp sönme animasyonu). Büyük
  slime gem yemez; elma/havuç yiyince 2 gem (iki türün birer gemi). Zıplama yüksekliği
  türe göre (`SlimeType.hop_height`). Yüz kareleri: normal,
  korkmuş (vakum), çiğneme, mutlu, tok.
- `scripts/pickup.gd` + `scenes/pickup.tscn` — `Pickup` (elma, havuç, gem). `hang(height,
  planted_look)`: kaynağa bağlı durma (ağaçtaki elma / toprağa gömülü havuç); vakumla
  çekilince `_detach()`. `consume_into()` ile yenir/satılır.
- `scripts/fruit_tree.gd` — `FruitTree` = genel **ürün kaynağı**: `produce` (ItemType),
  `slot_offsets`, `planted_look`, `regrow_time`, `bears_fruit` (false = süs ağacı).
  `scenes/fruit_tree.tscn` (elma, 60 sn), `scenes/carrot_patch.tscn` (havuç, toprak yığını,
  çarpışmasız — vakum görüş hattını kesmesin).

### Tavuklar
- `scripts/chicken.gd` + `scenes/chicken.tscn` — `Chicken extends Pickup`: tavuk, horoz,
  civciv (`data/items/hen|rooster|chick.tres`, `assets/chickens.png` 6 kare x 3 satır).
  `home` çevresinde yürür/gagalar (LEASH 56 px); fırlatılınca indiği yer yeni home.
  Civciv yenmez, `GROW_TIME`=120 oyun sn sonra tavuk/horoz olur (`grow_at` kayıtta).
- `scripts/chicken_nest.gd` + `scenes/chicken_nest.tscn` — `ChickenNest`: meyve ağacı
  mantığı; 72 px içinde 3'ten az kuş varsa 45 sn'de bir yenisi (civciv %50, tavuk %35,
  horoz %15). Çiftlikte 1, orman 1, yayla 1, dağ 3 yuva. Kayıtta `nests` = sayaçlar.
- Üreme henüz yok (kullanıcı sonra isteyebilir).

### Yeni yiyecekler ve kaya tavuğu
- Meyve: **Yıldız Meyvesi** (`star_fruit`, sarı yapraklı ağaç `star_fruit_tree.tscn`; yayla 2,
  dağ 1), **Ay Üzümü** (`moon_grape`, asma `grape_vine.tscn`, çarpışmasız; orman 3).
- Sebze: **Pancar** (`beet`, `beet_patch.tscn`; orman 2, yayla 1), **Buz Turpu** (`ice_radish`,
  `radish_patch.tscn`; dağ 3). Hepsi tarlaya ekilebilir (`GardenPlot.CROP_TREES`).
- **Kaya Tavuğu** (`rock_hen`, et) ve **Kaya Civcivi** (`rock_chick`, büyüyünce kaya tavuğu;
  `Chicken.GROWTH`). Taş yuva `chicken_nest_rock.tscn` (dağ 2, yayla 1); `ChickenNest`
  artık `spawn_ids` / `spawn_chances` export'larıyla ne çıkacağını seçer.
- `items.png` 18 satır (14-17 yeni yiyecekler), `chickens.png` 5 satır.

### Favori yiyecek
- `SlimeType.favorite`; `favorites()` büyük slimede iki türün favorisi. Favoriyi yiyince
  her gemden 2 tane + "Favori! x2" yazısı. Aç slime ikon gösterirken %50 favorisini gösterir.
- Favoriler: kırmızı elma, mavi pancar, gri kaya tavuğu, pembe yıldız meyvesi, kedi tavuk,
  tavşan havuç, mantar ay üzümü, ejder horoz, yaprak pancar, keçi buz turpu,
  kar yıldız meyvesi, tüy kaya tavuğu.

### Slime Kitabı
- `scripts/slime_book.gd` — `SlimeBook` (B ile aç/kapa, Esc kapatır). 12 tür ızgarası;
  keşfedilmemiş tür siyah siluet ve "???". Bilgiler: ad, resim, yaşadığı yer
  (`farm._slime_regions()`, INITIAL_SLIMES'tan), beslenme, favori, kısa tanım.
- Keşif: temel tür envantere ilk girdiğinde (`Inventory.contents_changed` ->
  `farm._check_discoveries`) bildirim + melodi. Büyük slime keşif sayılmaz.
  Kayıtta `discovered`; yüklerken envanterdeki slimelar sessizce keşfedilir.
- Debug paneli: "+Meyveler", "+Sebzeler", "+Etler", "Tümünü keşfet".

### Beslenme (diyet)
- `ItemType.food_kind` (FRUIT elma, VEGGIE havuç, MEAT tavuk/horoz, NONE civciv),
  `SlimeType.diet` bit maskesi (1 meyve, 2 sebze, 4 et). Büyük slime = iki diyetin birleşimi.
- Diyetler: meyve = kırmızı, mantar, kar; sebze = mavi, tavşan, yaprak, keçi;
  et = gri, kedi, ejder, tüy; pembe = hepsi.
- Aç slime yiyecek bulamazsa kafasında diyetinden bir yiyecek ikonu gösterir (7 sn'de bir).
- Besleyici sadece içerdeki aç bir slime'ın yiyebileceğini atar; civciv kabul etmez.

### Veri
- `scripts/item_type.gd` — `ItemType` (Resource): id, ad, kategori (SLIME/FOOD/GEM), ikon,
  `world_scene`, `sheet_row`, `max_stack`, `sell_price`, `spawn()`.
- `scripts/slime_type.gd` — `SlimeType extends ItemType`: zıplama hızı, bekleme, tokluk
  süresi, `gem`, `secondary` (büyük slime ise ikinci renk).
- `scripts/slime_registry.gd` — 12 temel tür, gem→slime,
  **büyük slime türlerini çalışma anında üretir**; çift SIRASIZ (mavi+gri = gri+mavi),
  66 kombinasyon, kimlik `large_<tür>_<tür>` (tür kimliklerinde `_` OLMAMALI).
- `scripts/slime_looks.gd` — `SlimeLooks`: tür satırı başına palet + özellik listesi
  (`stripes, cat_ears, cat_tail, bunny_ears, bunny_tail, cap, horns, dragon_tail, sprout`),
  `hybrid_pairs()` sırası. Hem görsel üretici hem registry kullanır.
- Türler (satır): 0 kırmızı, 1 mavi, 2 gri, 3 pembe (özelliksiz), 4 kedi (kulak, kuyruk,
  tekir çizgisi), 5 tavşan (uzun kulak, pamuk kuyruk), 6 mantar (benekli şapka),
  7 ejder (boynuz, dikenli kuyruk), 8 yaprak (filiz), 9 keçi (koç boynuzu, sakal),
  10 kar (kar örtüsü), 11 tüy (ibik, kanatlar) — son üçü dağlarda. Slime Rancher'dan esinli ama
  kendi tasarımlarımız (isim/görünüş kopyalanmadı).
- **Büyük slime görünüşü:** gövde küçük satırlı türün renginde, diğer türün rengi
  benekler halinde, iki türün TÜM özellikleri birlikte (özellikler sahibinin renginde).
- `scripts/item_database.gd` — kayıttaki id → ItemType (yeni .tres eklerken `ITEM_PATHS`'e ekle).
- `data/items/*.tres` (apple, carrot, red/blue/gray/pink_gem), `data/slimes/*.tres`.
- Fiyatlar: gem satış kırmızı 10, mavi 12, gri 15, pembe 20, kedi 25, tavşan 18,
  mantar 22, ejder 35, yaprak 14, keçi 30, kar 32, tüy 40.
- Doğma: orman = pembe, mavi, kedi, mantar, yaprak; yayla = gri, pembe, tavşan, ejder
  dağ = keçi, kar, tüy, gri (`farm.gd` `INITIAL_SLIMES`). Kayıtta `populated` = slime doğmuş
  bölgeler; yoksa (eski kayıt) farm/forest/highlands sayılır ve eksik bölgeler yüklenince doldurulur.

### Çiftlik / bahçe
- `scripts/house.gd`, `scenes/house.tscn` — ev dışı; kapı önü alanı → içeri.
- `scripts/house_interior.gd`, `scenes/house_interior.tscn` — tek oda, haritanın dışında
  (4096, 0) konumunda (dağlar eklenince 1024'ten taşındı; evde kayıtlıysa yüklemede
  `entry_spawn()` kullanılır), aynı sahnede (dış dünya içerideyken de yaşar). Yatak alanında E.
- `scripts/sell_machine.gd`, `scenes/sell_machine.tscn` — içine fırlatılan gemleri satar.
- `scripts/garden_plot.gd` — `GardenPlot`: evin önünde 10 arsa (`farm.gd` `PLOT_CELLS`).
  - Boş → **Slime Kümesi (300)**: cam duvarlar, köşe direkleri, kapasite 8 (büyük = 2);
    aşılırsa duvar kızarır, slimelar kaçabilir.
    - **Otomatik Besleyici (400)**: içine yiyecek at (30 kapasite, kuyruk); aç slime varsa
      ve yerde yiyecek yoksa 20 sn'de bir kümese atar.
    - **Otomatik Gem Toplayıcı (600)**: kümesteki gemleri vakumlayıp saklar, E ile envantere.
    - **Genişletme (800)**: kapasite 8 -> 16, cam duvarlar 10 -> 18 px yükselir (uzun direk).
  - Boş → **Tarla (150)**: içine elma/havuç at → fidan (180 sn) → elma ağacı / havuç yığını
    (sınırsız, 90 sn'de yenilenir). E ile menü.
    - **Gübre (350)**: büyüme ve yenilenme 2x hızlı (90 / 45 sn); ağacı yeniden kurmaz.
  - Kümes ve tarla menüsünde **Kaldır** (onaylı, ücretsiz, para iadesi yok): tarlada ağaçtaki
    ürünler yere düşer (`FruitTree.drop_all`), fidan varsa tohumu geri bırakılır; kümeste
    slimelara dokunulmaz, besleyici yiyecekleri ve toplayıcı gemleri yere bırakılır.
- `scripts/build_menu.gd` — satın alma penceresi (`assets/ui_theme.tres` ortak tema).

### Menü
- `scripts/main_menu.gd`, `scenes/main_menu.tscn` — Oyuna Başla → 3 slot (boş = yeni oyun,
  dolu = yükle, eski sürüm = gri/yüklenemez), her slotta onaylı "Sil" ("Emin?").

### Görseller
- Tüm piksel art `tools/generate_assets.gd` ile kodla üretilir:
  `godot --headless --path . -s res://tools/generate_assets.gd` sonra `--import`.
- Sprite sheet düzenleri:
  - `slimes.png`: 20x20 kareler, 11 sütun x 12 satır (tür). `slimes_icons.png`: 16x16 HUD ikonları.
  - `slimes_large.png`: 30x30, 11 x 66 (`SlimeLooks.hybrid_pairs()` sırası);
    `slimes_large_icons.png` 16x16.
  - `items.png`: 3 sütun (normal, parıltı, gömülü) x 14 satır (0 elma, 1-4 gem, 5 havuç,
    6-13 kedi/tavşan/mantar/ejder/yaprak/keçi/kar/tüy gemi).
  - `chickens.png` (tavuklar), `nest.png` (yuva).
  - `tiles.png`: 22 tile (0 çim … 13 orman örtüsü, 14 orman zemini, 15 mantar, 16 eğrelti,
    17 dağ zemini, 18 çakıl, 19 kar, 20 kaya duvarı (çarpışmalı), 21 dağ otu).
- Fizik katmanları: 1 world, 2 player, 3 slimes, 4 items, 5 corral.

## Kayıt sistemi
- `user://save_slot_<1..3>.json` (`%APPDATA%\Godot\app_userdata\Slime Farm\`).
- `SAVE_VERSION = 2`. Biçim/dünya kırıcı şekilde değişirse artır (eski kayıtlar "Eski sürüm").
- İçerik: player (alan + konum), inventory (+money), slimes, pickups (kaynağa bağlı olanlar
  hariç), trees (ürün kaynakları sırayla: çiftlik ağaçları, doğa ağaçları, havuç yığınları),
  plots, play_time, saved_at, nests, populated. Pickup girdilerinde `data` olabilir (civciv).
  Ürün kaynakları sırası: çiftlik ağaçları, doğa ağaçları, havuç yığınları, dağ ağaçları,
  dağ havuç yığınları.
- Kullanıcının slotları (2026-11-26): **Slot 1** = kullanıcının kendi oyunu;
  **Slot 2** = yeni test kaydı, 25.000 jeton (yeni türlerle). Testler **Slot 3**'ü kullanır ve sonunda siler.

## Test yöntemi
- Her değişiklikten sonra: `--headless --path . --quit` (menü sahnesini yükler).
- Davranış testleri: scratchpad'de `extends SceneTree` script'i, `-s <yol> --write-movie
  <klasör>/f.png --fixed-fps 60` ile çalıştır; kareleri PowerShell System.Drawing ile
  büyütüp incele. Slot 3'ü kullan, başında doluysa dur, sonunda sil.
- **Tuzak:** `-s` script'i autoload'lardan önce derlenir; `Game` kullanan sınıflara
  (Slime, DayNight, GardenPlot …) **tipli** başvurma → "Identifier not found: Game".
  Tipsiz değişken kullan, `Game`'e `root.get_node("Game")` ile eriş, oyunu `_initialize`'da
  değil ilk fizik karesinde başlat.
- **Tuzak:** `get_meta(key, null)` null varsayılanı "varsayılan yok" sayar → hata; `has_meta` kullan.
- Godot: `C:\Users\Ahmet\Desktop\Code\Godot\Godot_v4.6.2-stable_win64_console.exe`
  (oyunu kullanıcıya açmak için `_win64.exe`, `Start-Process`).

## Bilinen eksikler / sonraki adım fikirleri
- Oyun içinden ana menüye dönüş / duraklatma menüsü yok (Esc menüsü önerildi).
- Kümes, tarla ve geliştirmeler satıldıktan sonra kaldırılamıyor.
- Ana menüde slot ekranı açıkken panel dekor slimeları kapatıyor.
- Kümeste farklı renkler karışırsa toplayıcı yetişmeden gem yenip büyük slime oluşabilir.
- Kullanıcının planı: para harcanacak yeni sistemler, haritanın güzelleştirilmesi.

## Kronoloji (istek sırasıyla)
1. İskelet: hareket, 16x16 tile harita, çit + tarla.
2. Titreme düzeltmesi (physics interpolation), 8 yön, yürüme animasyonu.
3. 3 slime türü, zıplama, vakum (sağ çek / sol at), envanter, korkmuş yüz animasyonu.
4. Elma, açlık/tokluk (5 dk), gem verme, yeme/mutluluk animasyonları, 8 slot.
5. Başka renk gem → büyük iki renkli slime; büyük slime elma → 2 gem.
6. Fırlatılan nesneler slimelara çarpar; ana menü.
7. Melez simetrisi, yeni harita (ev, ağaçlar, doğa), ev içi, yatakta kayıt, 3 slot.
8. Gece-gündüz (3 dk), orman + yayla (doğal kenarlar), pembe slime, para + satış makinesi.
9. Kayıt silme + sürüm koruması, 10 bahçe arsası, kümes (+besleyici, +toplayıcı), tarla, test kaydı.
10. Kümes içinden atılan slime duvara çarpar; havuç + toprak yığınları.
11. 5 yeni özellikli tür (kedi, tavşan, mantar, ejder, yaprak); büyük slime artık iki
    türün özelliklerini birlikte taşır (yarı yarıya renk yerine); 25.000 jetonlu slot 2.
12. Tavuk/horoz/civciv + yuvalar; meyve/sebze/et diyetleri (büyük slime ikisini de yer);
    doğuda geniş dağlık bölge + 3 tür (keçi, kar, tüy); F1 debug paneli.
13. Sesler (koddan sentez, Sfx autoload), kümes genişletme (16), tarla süreleri makul + gübre, kümes/tarla kaldırma.
14. 2 yeni meyve + 2 yeni sebze (doğada kaynakları, tarlaya ekilebilir), kaya tavuğu ve taş
    yuvası, favori yiyecek (2x gem), Slime Kitabı (B) ve keşif bildirimi.
