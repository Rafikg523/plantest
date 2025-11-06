# PlanQR - Portainer Szybki Start 🚀

## Co to daje?

✅ **Automatyczne aktualizacje** - aplikacja sama pobiera nowe wersje z GitHub  
✅ **Łatwe zarządzanie** - wszystko przez interfejs webowy Portainer  
✅ **Zero budowania** - używa gotowych obrazów Docker  
✅ **Auto-restart** - kontenery same się uruchamiają po aktualizacji  

## Wymagania

- Docker zainstalowany
- Portainer zainstalowany (jeśli nie: `docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest`)

## Uruchomienie w 5 krokach

### 1. Przygotuj pliki na serwerze

```bash
mkdir -p /opt/planqr && cd /opt/planqr
mkdir -p data certs
```

### 2. Wygeneruj certyfikaty

```bash
curl -o generate-certs.sh https://raw.githubusercontent.com/Rafikg523/plantest/main/PlanQR/generate-certs.sh
chmod +x generate-certs.sh
./generate-certs.sh twoja-domena.com
# Zapamiętaj hasło!
```

### 3. Utwórz plik .env

```bash
nano .env
```

Wklej i wypełnij:
```env
JwtSettings__SecretKey=WYGENERUJ_LOSOWY_KLUCZ_32_ZNAKI
JwtSettings__Issuer=https://twoja-domena.com
JwtSettings__Audience=https://twoja-domena.com
SiteSettings__SiteUrl=https://twoja-domena.com
CertificateSettings__PfxPassword=HASLO_Z_KROKU_2
```

### 4. W Portainer dodaj Stack

1. Otwórz Portainer: `http://twoj-serwer:9000`
2. Przejdź do **Stacks** → **+ Add stack**
3. Nazwij: `planqr`
4. Wybierz **"Git Repository"**
5. Wpisz:
   - Repository URL: `https://github.com/Rafikg523/plantest`
   - Reference: `refs/heads/main`
   - Compose path: `PlanQR/docker-compose.portainer.yml`
6. W sekcji **Environment variables** dodaj zmienne z pliku .env
7. Kliknij **"Deploy the stack"**

### 5. Gotowe! 🎉

Aplikacja działa pod:
- Frontend: `http://twoj-serwer` lub `https://twoj-serwer`
- API: `https://twoj-serwer:5000`

## Automatyczne aktualizacje

Watchtower będzie:
- ✅ Sprawdzać aktualizacje co 5 minut
- ✅ Automatycznie pobierać nowe wersje
- ✅ Restartować aplikację z nowymi wersjami
- ✅ Usuwać stare obrazy

## Sprawdź czy działa

```bash
# Zobacz logi aktualizacji
docker logs -f planqr-watchtower

# Zobacz logi aplikacji
docker logs -f planqr-api
docker logs -f planqr-frontend
```

## Konfiguracja Watchtower

Możesz zmienić częstotliwość sprawdzania w Portainer:
1. Przejdź do **Stacks** → **planqr** → **Editor**
2. Znajdź sekcję `watchtower` → `environment`
3. Zmień `WATCHTOWER_POLL_INTERVAL=300` (300 = 5 minut)
4. Kliknij **Update the stack**

## Problemy?

### Obrazy nie są publiczne
Jeśli widzisz błąd `unauthorized`, sprawdź czy obrazy są publiczne:
- Przejdź do https://github.com/Rafikg523/plantest/pkgs/container/plantest%2Fapi
- Kliknij **Package settings** → **Change visibility** → **Public**

### Portainer nie może pobrać obrazów
W Portainer dodaj registry:
1. **Registries** → **+ Add registry**
2. Wybierz **GitHub**
3. Podaj swoje dane logowania GitHub

### Więcej pomocy
Zobacz pełną dokumentację: [PORTAINER.md](PORTAINER.md)

## Co dalej?

- 📖 Przeczytaj [PORTAINER.md](PORTAINER.md) - pełna dokumentacja
- 🔧 Skonfiguruj webhook dla natychmiastowych aktualizacji
- 💾 Ustaw automatyczne backupy bazy danych
- 🔒 Dodaj reverse proxy (Nginx Proxy Manager)
