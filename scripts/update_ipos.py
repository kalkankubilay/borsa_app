import os
import json
import urllib.request
from bs4 import BeautifulSoup

def fetch_top_completed_ipos():
    url = "https://halkarz.com"
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        }
    )
    try:
        html = urllib.request.urlopen(req, timeout=12).read().decode('utf-8', errors='ignore')
    except Exception as e:
        print(f"Error fetching main list: {e}")
        return []

    soup = BeautifulSoup(html, 'html.parser')
    articles = soup.find_all('article', class_='index-list')
    completed_list = []

    for art in articles[:5]: # Yalnızca son 5 tamamlanan
        try:
            symbol_el = art.find('span', class_='il-bist-kod')
            symbol = symbol_el.get_text(strip=True) if symbol_el else "BIST"
            
            title_el = art.find('h3') or art.find('a')
            company_name = title_el.get_text(strip=True) if title_el else ""
            link_tag = art.find('a')
            detail_url = link_tag['href'] if link_tag and 'href' in link_tag.attrs else ""
            
            date_el = art.find('time') or art.find('span', class_='il-halka-arz-tarihi')
            dates = date_el.get_text(strip=True) if date_el else "Tamamlandı"

            details = {}
            fund_usage = ""
            if detail_url:
                try:
                    d_req = urllib.request.Request(detail_url, headers={"User-Agent": "Mozilla/5.0"})
                    d_html = urllib.request.urlopen(d_req, timeout=6).read().decode('utf-8', errors='ignore')
                    d_soup = BeautifulSoup(d_html, 'html.parser')
                    for tr in d_soup.find_all('tr'):
                        tds = tr.find_all('td')
                        if len(tds) >= 2:
                            k = tds[0].get_text(strip=True).replace(':', '').strip()
                            v = tds[1].get_text(strip=True)
                            details[k] = v
                    for h in d_soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'strong', 'b']):
                        txt = h.get_text()
                        if 'Fonun Kullan' in txt or 'Fon Kullan' in txt:
                            nxt = h.find_next_sibling()
                            if nxt:
                                fund_usage = nxt.get_text().strip()
                            break
                except Exception:
                    pass

            price = details.get('Halka Arz Fiyatı/Aralığı', details.get('Halka Arz Fiyatı', 'Fiyat Bilgisi Yok'))
            lot_count = details.get('Pay', details.get('Lot', 'Belirtilmedi'))
            method = details.get('Dağıtım Yöntemi', 'Eşit Dağıtım')
            market = details.get('Pazar', 'Yıldız Pazar')
            lead_manager = details.get('Aracı Kurum', 'Konsorsiyum')

            completed_list.append({
                "id": symbol.lower(),
                "symbol": symbol,
                "companyName": company_name,
                "dates": dates,
                "price": price,
                "lotCount": lot_count,
                "distributionMethod": method,
                "market": market,
                "leadManager": lead_manager,
                "fundUsage": fund_usage if fund_usage else "• İzahname fon kullanım raporu tamamlandı.",
                "detailUrl": detail_url,
                "status": "completed"
            })
            print(f"Fetched Completed: {symbol} - {company_name}")
        except Exception as e:
            print(f"Error parsing completed card: {e}")

    return completed_list

def fetch_upcoming_ipos():
    url = "https://halkarz.com/k/taslak/"
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        }
    )
    try:
        html = urllib.request.urlopen(req, timeout=12).read().decode('utf-8', errors='ignore')
    except Exception as e:
        print(f"Error fetching taslak list: {e}")
        return []

    soup = BeautifulSoup(html, 'html.parser')
    articles = soup.find_all('article')
    ipo_list = []
    
    for art in articles[:10]:
        try:
            symbol_el = art.find('span', class_='il-bist-kod')
            symbol = symbol_el.get_text(strip=True) if symbol_el else ""
            
            title_el = art.find('h3') or art.find('h2') or art.find('a')
            if not title_el:
                continue
            
            company_name = title_el.get_text(strip=True)
            link_tag = art.find('a')
            detail_url = link_tag['href'] if link_tag and 'href' in link_tag.attrs else ""
            
            if not company_name or not detail_url.startswith("http"):
                continue

            if not symbol:
                words = company_name.split()
                symbol = words[0][:5].upper() if words else "TASLAK"

            fund_usage = ""
            details = {}
            if detail_url:
                try:
                    d_req = urllib.request.Request(detail_url, headers={"User-Agent": "Mozilla/5.0"})
                    d_html = urllib.request.urlopen(d_req, timeout=6).read().decode('utf-8', errors='ignore')
                    d_soup = BeautifulSoup(d_html, 'html.parser')
                    for tr in d_soup.find_all('tr'):
                        tds = tr.find_all('td')
                        if len(tds) >= 2:
                            k = tds[0].get_text(strip=True).replace(':', '').strip()
                            v = tds[1].get_text(strip=True)
                            details[k] = v
                    for h in d_soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'strong', 'b']):
                        txt = h.get_text()
                        if 'Fonun Kullan' in txt or 'Fon Kullan' in txt:
                            nxt = h.find_next_sibling()
                            if nxt:
                                fund_usage = nxt.get_text().strip()
                            break
                except Exception:
                    pass

            price = details.get('Halka Arz Fiyatı/Aralığı', details.get('Halka Arz Fiyatı', 'Taslak (Belirleniyor)'))
            lot_count = details.get('Pay', details.get('Lot', 'Taslak İzahname'))
            method = details.get('Dağıtım Yöntemi', 'Eşit Dağıtım (Taslak)')
            market = details.get('Pazar', 'Borsa İstanbul')
            lead_manager = details.get('Aracı Kurum', 'Konsorsiyum Lideri Belirleniyor')

            if not fund_usage:
                fund_usage = "• Şirketin taslak izahnamesi incelenmekte olup SPK onay bülteni beklenmektedir."

            ipo_list.append({
                "id": symbol.lower(),
                "symbol": symbol,
                "companyName": company_name,
                "dates": "SPK Başvuru Sürecinde (Henüz Talep Toplanmadı)",
                "price": price if "Hazırlan" not in price else "Taslak (Belirleniyor)",
                "lotCount": lot_count,
                "distributionMethod": method,
                "market": market,
                "leadManager": lead_manager,
                "fundUsage": fund_usage,
                "detailUrl": detail_url,
                "status": "upcoming"
            })
            print(f"Fetched Upcoming: {symbol} - {company_name}")
        except Exception as e:
            print(f"Error parsing card: {e}")

    return ipo_list

def main():
    print("Fetching upcoming IPOs...")
    upcoming = fetch_upcoming_ipos()
    
    print("Fetching top 5 completed IPOs...")
    completed = fetch_top_completed_ipos()
    
    # En fazla 5 adet tamamlanan halka arzı tutuyoruz (Rolling window of 5)
    all_ipos = upcoming + completed[:5]
    
    if not all_ipos:
        print("No IPOs fetched, skipping overwrite.")
        return

    output_path = os.path.join(os.path.dirname(__file__), "..", "data", "halka_arzlar.json")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(all_ipos, f, ensure_ascii=False, indent=2)
        
    print(f"Successfully saved {len(upcoming)} upcoming and {len(completed[:5])} completed IPOs to {output_path}")

if __name__ == "__main__":
    main()
