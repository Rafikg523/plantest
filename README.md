# PlanQR

## 🐳 Uruchomienie z Docker (Zalecane)

Aby uruchomić aplikację w Dockerze, zobacz:
- [DOCKER-QUICKSTART-PL.md](PlanQR/DOCKER-QUICKSTART-PL.md) - Szybki start lokalnie (Polski)
- [DOCKER.md](PlanQR/DOCKER.md) - Pełna dokumentacja Docker (English)

### 🚀 Portainer z automatycznymi aktualizacjami z GitHub ⭐
- [PORTAINER-QUICKSTART.md](PlanQR/PORTAINER-QUICKSTART.md) - **Szybki start Portainer (5 kroków)**
- [PORTAINER.md](PlanQR/PORTAINER.md) - Pełna dokumentacja Portainer

**Szybki start lokalnie:**
```bash
cd PlanQR
./docker-start.sh
```

## Instalacja bez Docker

### Wymagany jest .NET w wersji 8.0.0 oraz NodeJS w wersji 22.16.0
[Dokumentacja projektu](https://github.com/igorbebenek/PlanQR/blob/main/Dokumentacja.adoc)
## Instalacja pakietów

### W katalogu `API` wykonaj:
```
dotnet restore
```

### W katalogu `client-app` wykonaj:
```
npm ci
```

### W katalogu `Persistance` wykonaj
```
dotnet tool install --global dotnet-ef
dotnet database update
```
## Konifguracja serwera
a. W katalogu `API` w pliku `appsettings.json` należy uzupełnić puste pola  
b. W katalogu `Api\Properties` w pliku `launchSettings.json` należy uzupełnić "applicationUrl"  
c. W katalogu `client-app` w pliku `.env` należy uzupełnić URL do strony  
d. W katalogu `certs` umieścić pliki:
- cert.pfx
- cert.key
- cert.pem

## Uruchomienie aplikacji

### Aby uruchomić serwer backend w katalogu API wykonaj
```
dotnet run
```

### Aby uruchomić serwer frontend w katalogu client-app wykonaj
```
npm run dev
```
### Automatyczne przekierowanie z HTTP na HTTPS w projekcie (Windows Server)

1) Otworzyć `Internet Information Services (IIS) Manager`
2) W lewym oknie `Connections` kliknij dwukrotnie swoją stronę internetową
3) Kliknij `URL Rewrite` a następnie na `Add Rule(s)...`
4) Kliknij na `Blank rule`
5) W `Pater` trzeba wpisać `(.*)`
6) W `Conditions` kliknij na `Add`
7) W `Condition input` napisz `{HTTPS}` 
8) W `Patern`napisz `^OFF$` i kliknij na `Ok`
8) `Action type` zmienić na `Redirect`
9) W `Redirect URL` trzeba wpisać `https://{HTTP_HOST}/{R:1}`
10) Kliknij na `Apply`

Konfiguracja przekierowania zakończona 

### Konfiguracja tabletu 
Wykorzystywane oprogramowanie:
1) Fully Kiosk Browser:
  Odpowiada za uruchamianie aplikacji planu w trybie kiosku. Blokuje dostęp do innych aplikacji, ustawień systemowych czy przycisków. Zapewnia automatyczne włączanie aplikacji po starcie urządzenia. Utrzymuje ekran włączony podczas pracy. 
  Instalacja i konfiguracja: Aplikację pobiera się ze sklepu google play. W ustawieniach definiowana jset aplikacja startowa. Aktywowane są opcje blokady przycisków systemowych i utrzymania ekranu włączonego. 
2) AirDroid:
  Aplikacja umożliwia zdalną kontrolę i administrację tabletów z poziomu komputera. 
  Instalowany jest przez Google Play. Na każdym tablecie logujemy się na centralne konto administracyjne AirDroid. Przyznawane są wszystkie wymagane uprawnienia dla poprawnej pracy zdalnej. Na komputerze administracyjnym wykorzystywana jest aplikacja AirDroid Dekstop. 
  Wykorzystywany w wersji bezpłatnej.
