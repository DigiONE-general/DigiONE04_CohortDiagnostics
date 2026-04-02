# DigiONE04: Real-World Insights on Cancer Burden and Treatment Delays – A Comprehensive Observation Study Based on DigiONE Treatment Centres (DigiACT)

## Cohort Diagnostics

- CohortDiagnostics is an OHDSI tool which allows us to analyse and observe the coverage of our cohorts we have specified via ATLAS. See main documentation: https://ohdsi.github.io/CohortDiagnostics/

- This package contains main cohorts specific to DigiONE04 study - running this package will provide a full set of csv outputs documenting including concepts, summary statistics for cohort inclusion, index, incidence rate and more stored in a single output folder in your `cohortDiagnosticsResults` directory. These can be reviewed to assess 'missing' concepts from the cohort definitions or any inclusions which are incorrect/ unexpected.

- CohortDiagnostics results show cohort inclusion rule attrition, orphan codes (concepts which should be included in the cohort but are not included) and cohort overlap which are key in shaping cohort definition for DigiONE studies.

- This package also uses Rshiny to generate a dashboard interface from .sqlite file. This is generated at the end of `CodeToRun.R` - after running and generating results once you can use the View Results chunk at the end of CodeToRun.R to regenerate the results dashboard as you require.

---

## Requirements and run time

- **Run time:** system dependant — allow approx 60–75 minutes
- **R version:** 4.4.1 (required — `renv.lock` was created for this version)
- **Java:** required by some packages (see: https://ohdsi.github.io/Hades/rSetup.html)
- **Rtools44:** required for building packages from source (https://cran.r-project.org/bin/windows/Rtools/rtools44/rtools44.html)
- **Disk space:** allow up to 500 MB

---

## Running the code in RStudio

> **Note:** Open the folder as an R Project to enable renv functionality.

### 1. Configure credentials

Credentials are stored in a `.Renviron` file that is **excluded from git** for security.

```bash
# Copy the example file
cp .Renviron.example .Renviron
```

Fill in `.Renviron` with your database connection details:

```
DB_SERVER=
DB_PORT=5432
DB_NAME=
DB_UID=
DB_PWD=
```

> `.Renviron` is loaded automatically when you open the R Project. To reload manually:
> ```r
> readRenviron(".Renviron")
> ```

### 2. Restore the package library

Open `extras/CodeToRun.R` and run the setup section:

```r
install.packages("renv")
renv::restore()
```

> **Tip:** If `renv::restore()` hangs on packages requiring compilation, set before running:
> ```r
> options(install.packages.compile.from.source = "never")
> renv::restore()
> ```
>
> If restoring on **OneDrive**, pause synchronisation first to avoid file locking issues.

#### Known issues during renv::restore()

| Package | Problem | Solution |
|---------|---------|----------|
| `FeatureExtraction` | No binary available via RSPM | `renv::install("FeatureExtraction@3.12.0")` |
| `duckdb` | Source compilation hangs | `renv::record(list(duckdb = "1.5.1"))` then `renv::restore()` |

### 3. Run diagnostics

Execute `extras/CodeToRun.R` in RStudio. The script will:

1. Connect to the database using credentials from `.Renviron`
2. Generate cohort tables
3. Run CohortDiagnostics across all 13 cancer cohorts
4. Save results to `cohortDiagnosticsResults-<databaseId>/Results_<databaseId>.zip`

### 4. View results (optional)

The 'View Results' section at the end of `CodeToRun.R` launches an interactive Shiny dashboard:

```r
CohortDiagnostics::createMergedResultsFile(...)
CohortDiagnostics::launchDiagnosticsExplorer(...)
```

---

## Security — credentials

Credentials are **never stored in code**. The `extras/CodeToRun.R` script reads all connection parameters from environment variables:

```r
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms     = "postgresql",
  user     = Sys.getenv("DB_UID"),
  password = Sys.getenv("DB_PWD"),
  server   = paste0(Sys.getenv("DB_SERVER"), "/", Sys.getenv("DB_NAME")),
  port     = as.integer(Sys.getenv("DB_PORT")),
  ...
)
```

`.Renviron` is listed in `.gitignore` and will never be committed to the repository.

---

## Repository structure

```
.
├── extras/
│   ├── CodeToRun.R          # Main entry point — configure and run here
│   └── CodeToRun_example.R  # Example for alternative database setups
├── inst/
│   ├── cohorts/             # Cohort JSON definitions
│   ├── cohortsToCreate.csv  # Cohort metadata
│   └── sql/                 # SQL for cohort generation (postgresql / sql_server)
├── R/
│   └── runCohortDiagnostics.R  # Core diagnostics logic (sourced by CodeToRun.R)
├── .Renviron.example        # Credentials template (copy to .Renviron and fill in)
├── CHANGES_SUMMARY.md       # Detailed changelog
└── renv.lock                # Package versions lockfile
```

------------------------------------------------------------------------
