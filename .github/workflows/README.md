# GitHub Actions Workflows

## docker-build.yml

Ten workflow automatycznie buduje i publikuje obrazy Docker do GitHub Container Registry (GHCR).

### Kiedy uruchamia się workflow?

1. **Automatycznie** przy każdym push do gałęzi `main` lub `master`, jeśli zmieniono:
   - Pliki w katalogu `PlanQR/**`
   - Sam plik workflow `.github/workflows/docker-build.yml`

2. **Ręcznie** przez zakładkę "Actions" w GitHub (workflow_dispatch)

### Co robi workflow?

1. Buduje dwa obrazy Docker:
   - **API**: Backend .NET 8.0
   - **Frontend**: React + Nginx

2. Publikuje obrazy do GitHub Container Registry:
   - `ghcr.io/rafikg523/plantest/api:latest`
   - `ghcr.io/rafikg523/plantest/frontend:latest`

3. Tworzy dodatkowe tagi:
   - `{branch}` - nazwa gałęzi (np. `main`)
   - `{branch}-{sha}` - gałąź + hash commita (np. `main-abc1234`)
   - `latest` - tylko dla domyślnej gałęzi

### Konfiguracja

Workflow nie wymaga dodatkowej konfiguracji - używa wbudowanego `GITHUB_TOKEN`.

### Uprawnienia

Aby obrazy były dostępne publicznie:
1. Przejdź do https://github.com/Rafikg523/plantest/pkgs/container/plantest%2Fapi
2. Kliknij **Package settings**
3. Przewiń do sekcji **Danger Zone**
4. Kliknij **Change visibility** → **Public**
5. Powtórz dla obrazu frontend

### Ręczne uruchomienie

1. Przejdź do zakładki **Actions** w repozytorium
2. Wybierz **Build and Push Docker Images**
3. Kliknij **Run workflow**
4. Wybierz gałąź i kliknij **Run workflow**

### Monitorowanie

Sprawdź status budowania:
1. Zakładka **Actions** w repozytorium
2. Znajdź najnowszy workflow run
3. Kliknij aby zobaczyć szczegóły i logi

### Troubleshooting

#### Błąd: "denied: permission_denied"
Sprawdź czy workflow ma uprawnienia do zapisu pakietów:
- **Settings** → **Actions** → **General** → **Workflow permissions**
- Wybierz "Read and write permissions"

#### Obrazy nie są widoczne publicznie
Zobacz sekcję "Uprawnienia" powyżej

#### Build kończy się błędem
1. Sprawdź logi workflow w zakładce Actions
2. Upewnij się że kod buduje się lokalnie: `docker build -f PlanQR/API/Dockerfile PlanQR`
3. Sprawdź czy wszystkie zależności są dostępne
