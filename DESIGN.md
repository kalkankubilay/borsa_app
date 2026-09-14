# Design System: Borsa & Varlık Portföyüm (Spotify Minimal Dark)

## 1. Visual Theme & Atmosphere
- **Atmosphere:** Spotify estetiğinde derin, sade ve "quiet luxury" havasında karanlık tema (Dark Minimalism).
- **Density:** 5 (Dengeli, nefes alan, yormayan tipografi ve kart boşlukları).
- **Variance:** 4 (Hiyerarşik, net ve sezgisel gezinim).
- **Motion:** 5 (Yumuşak sekme geçişleri, micro-haptic yay animasyonları).
- **Tasarım Felsefesi:** Göz yormayan mat yüzeyler, gereksiz grafik kalabalığından arındırılmış temiz sayılar, yüksek kontrastlı metin ve Spotify'dan esinlenilmiş mat hap (pill) butonlar.

## 2. Color Palette & Roles
- **Onyx Canvas** (`#121212`) — Ana zemin (Saf `#000000` değil, derin Spotify koyusu).
- **Elevated Surface** (`#181818`) — Kartlar, liste elemanları ve alt panel arka planı.
- **Card Highlight / Active Tab** (`#282828`) — Seçili sekme, hover/tap durumları, ayrıştırıcı yüzey.
- **Subtle Border** (`#2E2E2E` veya `rgba(255, 255, 255, 0.08)`) — İnce 1px zarif sınırlar.
- **Text Primary (Snow)** (`#FFFFFF`) — Toplam portföy değeri, hisse kodları, ana başlıklar.
- **Text Secondary (Muted Ash)** (`#A7A7A7`) — Alış fiyatı, adet bilgisi, alt yazılar.
- **Gain Emerald** (`#1ED760`) — Spotify yeşili tonunda kâr göstergesi ve ana aksan rengi.
- **Loss Crimson** (`#F15E6C`) — Dengeli, göz almayan kırmızı (zarar durumları için).
- **Gold Accent** (`#F3BA2F`) — Altın ve değerli madenler için mat altın vurgusu.

## 3. Typographic Architecture
- **Font Ailesi:** `Plus Jakarta Sans` veya `Outfit` (Modern, net, geometrik; Inter yasak).
- **Rakamlar (Monospace):** `JetBrains Mono` veya tabular figures (Değerler ve yüzdeler hizalı akar, rakamlar titreme yapmaz).
- **Hiyerarşi:**
  - **Portfolio Total Hero:** 36px, Bold, tracking -1px (Ekranın tepe noktası).
  - **Section / Screen Title:** 22px, Semi-Bold.
  - **Asset Symbol / Name:** 16px, Medium, `#FFFFFF`.
  - **Financial Metrics (Numbers):** 14px, Monospace Semi-Bold.
  - **Metadata & Subtext:** 12px, Regular, `#A7A7A7`.

## 4. Screens & Information Architecture

### Ekran 1: Genel Bakış & Konsolide Portföy (Home / Overview)
- **Top Bar:** Tarih, portföy para birimi seçici (USD / TRY dönüşüm göstergesi) ve gizlilik göz ikonu (bakiye gizleme).
- **Hero Card (Konsolide Net Değer):**
  - "Toplam Portföy Değeri" (Örn: `₺1.248.500,00` veya `$38.450,00`).
  - Toplam Kâr/Zarar: `+₺184.200,00 (%17.3)` (Yeşil veya Kırmızı hap etiket).
- **Varlık Dağılımı Çubuğu (Asset Allocation Bar):**
  - Tek satırda orantılı yatay bar: TR Borsası (Mavi/Beyaz), ABD Borsası (Mor/Gri), Altın (Altın Sarısı).
- **Hızlı Özet Kartları (3 Mini Kart):**
  - **TR Portföyü:** Değer + Günlük Değişim.
  - **ABD Portföyü:** Değer (USD ve TRY karşılığı) + Değişim.
  - **Altın / Emtia:** Gram/Ons Değeri + Değişim.
- **Son İşlemler / Hızlı Hareketler:** En son eklenen alım/satım kayıtları.

### Ekran 2: Varlık Detayı & Sekmeli Portföy Takibi (Asset Segments)
- **Spotify Tarzı Hap Sekmeler (Pill Segmented Control):**
  - `[ Tümü ]` | `[ 🇹🇷 BIST / TR ]` | `[ 🇺🇸 ABD Borsası ]` | `[ 🪙 Altın / Emtia ]`
  - Yatay kaydırılabilir, seçilen sekme `#FFFFFF` dolgulu siyah yazılı (veya `#282828` aktif durumlu), pasifler şeffaf.
- **Sekme Özet Başlığı:**
  - Seçili sekmenin toplam değeri ve o kategoriye özel toplam kâr/zarar.
- **Varlık Liste Kartları (Her Hisse / Altın İçin):**
  - **Sol Taraf:**
    - Varlık Kodu (Örn: `THYAO`, `AAPL`, `Gram Altın`).
    - Alış Adedi & Ort. Alış Maliyeti (Örn: `45 Adet • Maliyet: ₺265.40`).
    - Alış Tarihindeki Toplam Tutar (Maliyet Değeri: `₺11.943`).
  - **Sağ Taraf:**
    - Güncel Fiyat & Güncel Toplam Değer (Örn: `₺310.20` ➡️ `₺13.959`).
    - Net Kâr/Zarar Tutarı ve Yüzdesi (`+₺2.016 (%16.8)` yeşil/kırmızı rozet).

## 5. Component Stylings & Interaction
- **Pill Tabs:** 36px yükseklik, yumuşak yuvarlak kenarlar (`radius: 20px`), dokunulduğunda haptic geri bildirim ve pürüzsüz geçiş.
- **Asset Row:** Kenarlıklı veya hafif mat arka planlı (`#181818`), dokunulduğunda hafif koyulaşan aktif durum. Asla parlak gölge yok.
- **Bottom Navigation Bar:** Spotify gibi sabit siyah zemin (`#121212`), 2 ana sekme: `[Özet]` ve `[Portföyüm]` + hızlı varlık ekleme `[+]` butonu.

## 6. Anti-Patterns (Banned)
- ❌ Cırtlak neon gradyanlar ve mor AI gölgeleri yok.
- ❌ Saf siyah (`#000000`) zemin yok; mat `#121212` kullanılacak.
- ❌ Kalabalık ve gereksiz gösterge çizgileri yok; net sayılar ve net oranlar ön planda.
- ❌ Inter fontu yok (`Plus Jakarta Sans` + `JetBrains Mono` kullanılacak).
