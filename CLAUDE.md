# Slime Farm
- Godot 4.6, 2D, GDScript 2.0 (statik tipleme kullan)
- Piksel art: 16x16 tile, 16x16 karakter, nearest filtreleme (Project Settings > Rendering > Textures > Default Texture Filter: Nearest)
- Harita için TileMapLayer kullan (TileMap değil)
- Sahneler scenes/, scriptler scripts/, görseller assets/ altında; eşya/slime verisi data/ altında (.tres)
- Her değişiklikten sonra `godot --headless --path . --quit` ile script hatalarını kontrol et
- Yorum ve arayüz metinleri Türkçe olabilir, kod adları İngilizce

## Devam ederken
- Tüm sistemlerin özeti, dosya haritası, kayıt biçimi, test yöntemi ve bilinen eksikler: `docs/DEVLOG.md` — işe başlamadan oku, iş bitince güncelle.
- Görseller kodla üretilir: `tools/generate_assets.gd` (çalıştır, sonra `--import`). Elle PNG düzenleme.
- Dünya sabit tohumlu üretilir (`scripts/world_gen.gd`); yeni prop yerleşimlerini listelerin SONUNA ekle ki kayıtlardaki sıra bozulmasın.
- Kayıt biçimi kırıcı şekilde değişirse `Game.SAVE_VERSION`'ı artır.
- Davranış testlerinde sadece kayıt Slot 3'ü kullan ve sonunda sil; kullanıcının Slot 1/2'sine yazma.
- Ekran geçişlerinde oyuncuyu `process_mode` ile dondurma, `player.input_enabled` kullan.
