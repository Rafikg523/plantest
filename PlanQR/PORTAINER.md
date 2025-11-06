# PlanQR - Portainer z Automatycznymi Aktualizacjami

## Opis

Ten przewodnik wyjaśnia jak uruchomić PlanQR przez Portainer z automatycznym pobieraniem aktualizacji z GitHub.

## Jak to działa

1. **GitHub Actions** - Każda zmiana w kodzie automatycznie buduje i publikuje nowe obrazy Docker do GitHub Container Registry (GHCR)
2. **Portainer** - Zarządza uruchomieniem kontenerów używając gotowych obrazów z GHCR
3. **Watchtower** - Monitoruje obrazy Docker i automatycznie aktualizuje kontenery gdy pojawią się nowe wersje

## Wymagania

- Serwer z zainstalowanym Docker
- Portainer zainstalowany i działający
- Dostęp do internetu (do pobierania obrazów z GitHub)

## Instalacja Portainer (jeśli jeszcze nie masz)

```bash
# Utwórz volume dla danych Portainer
docker volume create portainer_data

# Uruchom Portainer
docker run -d \
  -p 9000:9000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

Następnie otwórz przeglądarkę pod adresem `http://twoj-serwer:9000` i utwórz konto administratora.

## Konfiguracja PlanQR w Portainer

### Metoda 1: Przez Stack (Zalecane)

1. **Zaloguj się do Portainer** (http://twoj-serwer:9000)

2. **Przejdź do Stacks** w menu bocznym

3. **Kliknij "+ Add stack"**

4. **Wypełnij dane:**
   - **Name**: `planqr`
   - **Build method**: Wybierz "Git Repository"
   - **Repository URL**: `https://github.com/Rafikg523/plantest`
   - **Repository reference**: `refs/heads/main` (lub `master`)
   - **Compose path**: `PlanQR/docker-compose.portainer.yml`

5. **Dodaj zmienne środowiskowe** (kliknij "+ Add an environment variable"):

   **Wymagane zmienne:**
   ```
   JwtSettings__SecretKey=TWOJ_BEZPIECZNY_KLUCZ_MIN_32_ZNAKI
   JwtSettings__Issuer=https://twoja-domena.com
   JwtSettings__Audience=https://twoja-domena.com
   SiteSettings__SiteUrl=https://twoja-domena.com
   CertificateSettings__PfxPassword=TWOJE_HASLO_DO_CERTYFIKATU
   ```

   **Opcjonalne (LDAP):**
   ```
   LdapSettings__Server=ldap://twoj-serwer-ldap
   LdapSettings__Port=389
   LdapSettings__BaseDn=dc=example,dc=com
   LdapSettings__Username=cn=admin,dc=example,dc=com
   LdapSettings__Password=haslo-ldap
   ```

6. **Kliknij "Deploy the stack"**

### Metoda 2: Przez Plik docker-compose (Alternatywna)

1. **Przygotuj pliki na serwerze:**

```bash
# Utwórz katalog dla aplikacji
mkdir -p /opt/planqr
cd /opt/planqr

# Pobierz plik docker-compose
curl -o docker-compose.yml https://raw.githubusercontent.com/Rafikg523/plantest/main/PlanQR/docker-compose.portainer.yml

# Utwórz katalogi dla danych i certyfikatów
mkdir -p data certs
```

2. **Utwórz plik .env:**

```bash
cat > .env << 'EOF'
# JWT Settings
JwtSettings__SecretKey=TWOJ_BEZPIECZNY_KLUCZ_MIN_32_ZNAKI
JwtSettings__Issuer=https://twoja-domena.com
JwtSettings__Audience=https://twoja-domena.com

# Site Settings
SiteSettings__SiteUrl=https://twoja-domena.com

# Certificate Settings
CertificateSettings__PfxPassword=TWOJE_HASLO_DO_CERTYFIKATU

# LDAP Settings (opcjonalne)
# LdapSettings__Server=ldap://twoj-serwer-ldap
# LdapSettings__Port=389
# LdapSettings__BaseDn=dc=example,dc=com
# LdapSettings__Username=cn=admin,dc=example,dc=com
# LdapSettings__Password=haslo-ldap
EOF
```

3. **Wygeneruj certyfikaty SSL:**

```bash
# Pobierz skrypt generowania certyfikatów
curl -o generate-certs.sh https://raw.githubusercontent.com/Rafikg523/plantest/main/PlanQR/generate-certs.sh
chmod +x generate-certs.sh

# Wygeneruj certyfikaty (zmień localhost na swoją domenę)
./generate-certs.sh twoja-domena.com
```

4. **W Portainer:**
   - Przejdź do **Stacks**
   - Kliknij **"+ Add stack"**
   - **Name**: `planqr`
   - Wybierz **"Upload from computer"** lub **"Web editor"**
   - Wklej zawartość `docker-compose.yml`
   - W sekcji **Environment variables** zaznacz "Load variables from .env file"
   - Wskaż ścieżkę: `/opt/planqr/.env`
   - Kliknij **"Deploy the stack"**

## Automatyczne Aktualizacje

Watchtower jest już skonfigurowany w `docker-compose.portainer.yml` i będzie:
- Sprawdzać nowe wersje obrazów co 5 minut (300 sekund) - **dla testów i developmentu**
- Automatycznie pobierać nowe obrazy
- Restartować kontenery z nowymi wersjami
- Usuwać stare obrazy po aktualizacji

⚠️ **Dla produkcji**: Rozważ zwiększenie interwału do 3600 sekund (1 godzina) lub więcej, aby zmniejszyć obciążenie sieci i zasobów. Alternatywnie, użyj webhooków dla natychmiastowych aktualizacji (patrz sekcja "Webhook" poniżej).

### Monitorowanie Watchtower

Sprawdź logi Watchtower:
```bash
docker logs -f planqr-watchtower
```

### Konfiguracja Watchtower

Możesz dostosować ustawienia Watchtower w pliku `docker-compose.portainer.yml`:

```yaml
watchtower:
  environment:
    - WATCHTOWER_POLL_INTERVAL=300   # Interwał sprawdzania w sekundach
                                      # 300 = 5 minut (development/test)
                                      # 3600 = 1 godzina (produkcja)
                                      # 86400 = 24 godziny (stabilna produkcja)
    - WATCHTOWER_CLEANUP=true        # Usuń stare obrazy po aktualizacji
    - WATCHTOWER_NOTIFICATIONS=email # Powiadomienia email (wymaga dodatkowej konfiguracji)
```

## Zarządzanie Aplikacją

### Przez Portainer UI

1. **Zatrzymaj/Uruchom kontenery:**
   - Przejdź do **Stacks** → **planqr**
   - Kliknij **Stop** lub **Start**

2. **Przebuduj z najnowszymi obrazami:**
   - Przejdź do **Stacks** → **planqr**
   - Kliknij **Pull and redeploy**

3. **Zobacz logi:**
   - Przejdź do **Containers**
   - Kliknij na kontener (np. `planqr-api`)
   - Kliknij **Logs**

### Przez CLI

```bash
# Zobacz status
docker ps | grep planqr

# Zobacz logi
docker logs -f planqr-api
docker logs -f planqr-frontend

# Restartuj kontenery
docker restart planqr-api
docker restart planqr-frontend

# Wymuś aktualizację
docker restart planqr-watchtower
```

## Dostęp do Aplikacji

Po uruchomieniu:
- **Frontend**: http://twoj-serwer lub https://twoj-serwer:443
- **API**: https://twoj-serwer:5000

## Webhook dla Natychmiastowych Aktualizacji

Możesz skonfigurować webhook w GitHub, aby Watchtower natychmiast sprawdzał aktualizacje po każdym push:

1. **Skonfiguruj Watchtower HTTP API:**

Edytuj plik `docker-compose.portainer.yml`:
```yaml
watchtower:
  environment:
    - WATCHTOWER_HTTP_API_TOKEN=twoj-bezpieczny-token
    - WATCHTOWER_HTTP_API_UPDATE=true
  ports:
    - "8080:8080"
```

2. **Dodaj webhook w GitHub:**
   - Przejdź do ustawień repozytorium na GitHub
   - **Settings** → **Webhooks** → **Add webhook**
   - **Payload URL**: `http://twoj-serwer:8080/v1/update`
   - **Content type**: `application/json`
   - **Secret**: `twoj-bezpieczny-token`
   - Wybierz **Just the push event**
   - Kliknij **Add webhook**

## Backup Bazy Danych

Ważne: Regularnie twórz kopie zapasowe bazy danych!

```bash
# Backup
docker exec planqr-api tar czf - /app/data/PlanQRDB.db > backup-$(date +%Y%m%d).tar.gz

# Restore
docker exec -i planqr-api tar xzf - -C /app/data < backup-20240101.tar.gz
docker restart planqr-api
```

Możesz też skonfigurować automatyczne backupy w Portainer używając cron job lub dodatkowego kontenera.

## Troubleshooting

### Obrazy nie są pobierane

1. **Sprawdź czy obrazy są publiczne:**
   ```bash
   docker pull ghcr.io/rafikg523/plantest/api:latest
   docker pull ghcr.io/rafikg523/plantest/frontend:latest
   ```

2. **Jeśli obrazy są prywatne, dodaj uwierzytelnienie:**
   - W GitHub: Settings → Developer settings → Personal access tokens
   - Utwórz token z uprawnieniem `read:packages`
   - W Portainer: Registries → Add registry → GitHub
   - Podaj swoje dane logowania

### Watchtower nie aktualizuje kontenerów

1. Sprawdź logi Watchtower:
   ```bash
   docker logs planqr-watchtower
   ```

2. Upewnij się że Watchtower ma dostęp do Docker socket:
   ```bash
   docker inspect planqr-watchtower | grep /var/run/docker.sock
   ```

3. Wymuś aktualizację:
   ```bash
   docker restart planqr-watchtower
   ```

### Problemy z certyfikatami

```bash
# Sprawdź czy certyfikaty istnieją
ls -la /opt/planqr/certs/

# Wygeneruj nowe certyfikaty
cd /opt/planqr
./generate-certs.sh twoja-domena.com

# Zaktualizuj hasło w .env
nano .env  # Ustaw CertificateSettings__PfxPassword
```

### Port już używany

Edytuj porty w `docker-compose.portainer.yml`:
```yaml
ports:
  - "8080:80"    # Frontend HTTP
  - "8443:443"   # Frontend HTTPS
  - "5001:5000"  # API
```

## Aktualizacja Ręczna (bez Watchtower)

Jeśli chcesz kontrolować aktualizacje ręcznie:

1. Usuń kontener Watchtower z `docker-compose.portainer.yml`

2. Aktualizuj ręcznie:
   ```bash
   # Pobierz nowe obrazy
   docker pull ghcr.io/rafikg523/plantest/api:latest
   docker pull ghcr.io/rafikg523/plantest/frontend:latest
   
   # W Portainer: Stacks → planqr → Pull and redeploy
   ```

## Produkcja

⚠️ **Dla środowiska produkcyjnego:**

1. **Używaj prawdziwych certyfikatów SSL** (np. Let's Encrypt z Certbot)
2. **Skonfiguruj reverse proxy** (Nginx Proxy Manager, Traefik)
3. **Regularnie twórz backupy** bazy danych
4. **Monitoruj logi i zasoby** przez Portainer
5. **Używaj silnych, losowych haseł** w .env
6. **Rozważ użycie Docker Secrets** zamiast plików .env
7. **Ogranicz dostęp do Portainer** (firewall, VPN)

## Więcej Informacji

- [Dokumentacja Portainer](https://docs.portainer.io/)
- [Dokumentacja Watchtower](https://containrrr.dev/watchtower/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Documentation](https://docs.docker.com/)

## Wsparcie

W razie problemów:
1. Sprawdź logi kontenerów w Portainer
2. Przeczytaj sekcję Troubleshooting powyżej
3. Zobacz dokumentację: [DOCKER.md](DOCKER.md) i [DOCKER-QUICKSTART-PL.md](DOCKER-QUICKSTART-PL.md)
4. Zgłoś issue na GitHub
