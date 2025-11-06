# PlanQR - Docker Quick Start (Polski)

## Szybki Start z Dockerem 🐳

### 1. Wymagania
- Docker Engine 20.10 lub nowszy
- Docker Compose 2.0 lub nowszy

### 2. Instalacja i uruchomienie (3 kroki)

#### Krok 1: Przejdź do katalogu PlanQR
```bash
cd PlanQR
```

#### Krok 2: Użyj skryptu pomocniczego
```bash
./docker-start.sh
```

Skrypt przeprowadzi Cię przez:
- Generowanie certyfikatów SSL
- Konfigurację plików .env
- Uruchomienie aplikacji

#### Krok 3: Otwórz aplikację
- **Frontend**: http://localhost
- **API**: https://localhost:5000

## Konfiguracja manualna

Jeśli wolisz skonfigurować ręcznie:

### 1. Wygeneruj certyfikaty SSL
```bash
./generate-certs.sh localhost
```
Zapamiętaj hasło - będzie potrzebne w następnym kroku.

### 2. Skopiuj przykładowe pliki konfiguracyjne
```bash
cp .env.example .env
cp client-app/.env.example client-app/.env
```

### 3. Edytuj plik `.env`
Wypełnij wymagane wartości:
```env
JwtSettings__SecretKey=twoj-sekretny-klucz-minimum-32-znaki
JwtSettings__Issuer=https://twoja-domena.com
JwtSettings__Audience=https://twoja-domena.com
SiteSettings__SiteUrl=https://twoja-domena.com
CertificateSettings__PfxPassword=haslo-z-kroku-1
```

### 4. Edytuj plik `client-app/.env`
```env
VITE_SITE_URL=https://twoja-domena.com
```

### 5. Utwórz katalog na dane
```bash
mkdir -p data
```

### 6. Uruchom aplikację
```bash
docker compose up -d
```

## Podstawowe polecenia

### Wyświetl logi
```bash
# Wszystkie serwisy
docker compose logs -f

# Tylko API
docker compose logs -f api

# Tylko Frontend
docker compose logs -f frontend
```

### Zatrzymaj aplikację
```bash
docker compose down
```

### Restartuj aplikację
```bash
docker compose restart
```

### Przebuduj po zmianach w kodzie
```bash
docker compose up -d --build
```

### Zatrzymaj i usuń wszystko (⚠️ usuwa bazę danych)
```bash
docker compose down -v
rm -rf data
```

## Struktura projektu Docker

```
PlanQR/
├── docker-compose.yml          # Główna konfiguracja Docker
├── docker-start.sh             # Pomocniczy skrypt startowy
├── generate-certs.sh           # Skrypt generowania certyfikatów
├── .env.example                # Przykładowa konfiguracja backend
├── .env                        # Twoja konfiguracja backend (nie commituj!)
├── API/
│   └── Dockerfile              # Dockerfile dla API (.NET)
├── client-app/
│   ├── Dockerfile              # Dockerfile dla frontendu (React)
│   ├── nginx.conf              # Konfiguracja Nginx
│   ├── .env.example            # Przykładowa konfiguracja frontend
│   └── .env                    # Twoja konfiguracja frontend (nie commituj!)
├── certs/                      # Certyfikaty SSL (nie commituj!)
│   ├── cert.key
│   ├── cert.pem
│   └── cert.pfx
└── data/                       # Baza danych SQLite (nie commituj!)
    └── PlanQRDB.db
```

## Rozwiązywanie problemów

### Problemy z certyfikatami
```bash
# Usuń stare certyfikaty
rm -f certs/cert.*

# Wygeneruj nowe
./generate-certs.sh localhost

# Zaktualizuj hasło w .env
nano .env  # Ustaw CertificateSettings__PfxPassword
```

### Konflikt portów
Jeśli porty 80, 443 lub 5000 są zajęte, edytuj `docker-compose.yml`:
```yaml
ports:
  - "8080:80"   # Frontend HTTP
  - "8443:443"  # Frontend HTTPS
  - "5001:5000" # API
```

### Problemy z bazą danych
```bash
# Usuń bazę i pozwól się jej odtworzyć
rm -rf data/*
docker compose restart api
```

### Kontenery nie startują
```bash
# Sprawdź logi
docker compose logs

# Sprawdź czy masz wystarczająco zasobów
docker system df

# Wyczyść nieużywane kontenery i obrazy
docker system prune -a
```

## Produkcja

⚠️ **Dla środowiska produkcyjnego:**

1. **Użyj prawdziwych certyfikatów SSL** (np. Let's Encrypt)
2. **Użyj silnych, losowych haseł** w .env
3. **Skonfiguruj backup bazy danych** (katalog `data/`)
4. **Rozważ użycie reverse proxy** (Nginx, Traefik)
5. **Ustaw limity zasobów** w docker-compose.yml
6. **Użyj bardziej zaawansowanej bazy danych** (PostgreSQL, MySQL)

Szczegółowe instrukcje w [DOCKER.md](DOCKER.md)

## Wsparcie

Dla szczegółowej dokumentacji zobacz:
- [DOCKER.md](DOCKER.md) - Pełna dokumentacja Docker
- [README.md](../README.md) - Główna dokumentacja projektu
