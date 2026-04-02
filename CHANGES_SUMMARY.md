# Podsumowanie zmian w repozytorium DigiONE04_CohortDiagnostics_NIO

## Zalecane kroki na start nowego czatu

```r
# 1. Załaduj credentiale (jeśli sesja nie wczytała .Renviron automatycznie)
readRenviron(".Renviron")

# 2. Sprawdź czy zmienne są widoczne
Sys.getenv("DB_SERVER")
Sys.getenv("DB_PORT")

# 3. Uruchom analizę z CodeToRun.R
source(here::here("extras/CodeToRun.R"))
```

---

## Środowisko R

### Konfiguracja

`renv.lock` stworzony dla **R 4.4.1**. Należy używać tej wersji R.

W przypadku problemów z kompilacją pakietów ze źródeł, ustawić przed `renv::restore()`:
```r
options(install.packages.compile.from.source = "never")
```

### Problemy napotkane podczas renv::restore()

#### FeatureExtraction 3.12.0
Pakiet nie był dostępny jako binarny z RSPM (błąd HTTP 22 dla URL z `/4.4/`).
Zainstalowany ręcznie komendą:
```r
renv::install("FeatureExtraction@3.12.0")
```

#### duckdb 1.4.4
Kompilacja ze źródeł powodowała zawieszenie sesji (duża biblioteka C++).
Rozwiązanie — aktualizacja wpisu w lockfile do wersji binarnej 1.5.1:
```r
renv::record(list(duckdb = "1.5.1"))
renv::restore()
```

#### OneDrive — blokowanie plików
Projekt zlokalizowany na OneDrive powodował zawieszenia podczas instalacji pakietów
(OneDrive synchronizował pliki w trakcie zapisu).
**Rozwiązanie:** Wstrzymać synchronizację OneDrive przed uruchomieniem `renv::restore()`.

---

## Bezpieczeństwo — credentiale

### Problem
`extras/CodeToRun.R` zawierał hardkodowane dane logowania do bazy danych
(user, password, server) bezpośrednio w kodzie źródłowym.

### Zmiany

**Nowe pliki:**
- `.Renviron` — zawiera rzeczywiste credentiale (dodany do `.gitignore`, NIE trafia do git)
- `.Renviron.example` — szablon dla innych użytkowników (trafia do git)

**Zmodyfikowane pliki:**
- `.gitignore` — dodano `.Renviron`
- `extras/CodeToRun.R` — hardkodowane credentiale zastąpione `Sys.getenv()`

```r
# PRZED
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  user = "hpawlik",
  password = "g489Kn40-3SxdT2n",
  server = "192.168.202.50/omop",
  port = 5432,
  ...
)

# PO
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  user = Sys.getenv("DB_UID"),
  password = Sys.getenv("DB_PWD"),
  server = paste0(Sys.getenv("DB_SERVER"), "/", Sys.getenv("DB_NAME")),
  port = as.integer(Sys.getenv("DB_PORT")),
  ...
)
```

**Jak skonfigurować nowe środowisko:**
```bash
cp .Renviron.example .Renviron
# Wypełnij .Renviron swoimi danymi
```

Zmienne w `.Renviron`:
```
DB_SERVER=
DB_PORT=5432
DB_NAME=
DB_UID=
DB_PWD=
```

---

## Lista wszystkich zmodyfikowanych plików

| Plik | Zmiana |
|------|--------|
| `.gitignore` | dodano `.Renviron` |
| `.Renviron` | nowy — credentiale (NIE w git) |
| `.Renviron.example` | nowy — szablon (w git) |
| `extras/CodeToRun.R` | credentiale → Sys.getenv() |
| `renv.lock` | zaktualizowany przez `renv::snapshot()` po instalacji brakujących pakietów |
