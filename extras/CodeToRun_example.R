# Activate renv, if not already activated.
renv::activate()

# Restore the packages.
renv::restore()

# Helper function
load_or_install <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# Load Libraries
load_or_install("omopgenerics")
load_or_install("CDMConnector")
load_or_install("odbc")
load_or_install("dplyr")
load_or_install("here")
load_or_install("CohortGenerator")
load_or_install("shinyjs")
load_or_install("CohortCharacteristics")
load_or_install("DatabaseConnector")
load_or_install("FeatureExtraction")


# [*] EDIT BELOW ==============================================================

databaseId <- "USA_ONCEMR" 
cdmDatabaseSchema <- "EXT_OMOPV5_USA_ONCEMR.FULL_M202112_OMOP_V5"
writeDatabaseSchema <- "PA_USA_ONCEMR.STUDY_REFERENCE"
tablePrefix <- "digione4_pancancer_"
minCellCount <- 5
sql_dialect <- "sqlserver" #'sqlserver' - will run standard OHDSI.sql 
                          #'postgres' - will run PostgreSQL dialect
#if blank will default to OHDSI sqlserver compatible

server <- Sys.getenv("OMOP_PA_SERVER")
warehouse <- Sys.getenv("MEDIUM_USA_ONCEMR")
db <- '&db=PA_USA_ONCEMR'
cohortSchema = "STUDY_REFERENCE"

# 1.  COHORT DIAGNOSTICS

### Connect to writable schema
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "snowflake",
  connectionString = paste0(server,warehouse, db, "&schema=", cohortSchema),
  user = Sys.getenv("SNOWFLAKE_USER"),
  password ="",
  pathToDriver = "~/drivers"
)

connection <- DatabaseConnector::connect(connectionDetails)


# Some database platforms like Oracle and Impala do not truly support temp
# tables. To emulate temp tables, provide a schema with write privileges where
# temp tables can be created.
tempEmulationSchema <- NULL

# The name of the table that will be created in the cohortDatabaseSchema
cohortTable <- paste0("tmp_cohort_", as.integer(Sys.time()) %% 10000)


# [!] DO NOT EDIT BELOW =======================================================

# A folder with cohorts
cohortsFolder <- here::here("inst", "cohorts")

# A folder on the local file system to store results
cohortOutputDir <- here::here(paste("cohortDiagnosticsResults-",databaseId))

if (!file.exists(cohortOutputDir)) {
    dir.create(cohortOutputDir, recursive = TRUE)
}

# [*] RUN DIAGNOSTICS =========================================================

source(here::here("R/runCohortDiagnostics.R"))

# [*] VIEW RESULTS ============================================================

# To view the shiny app run the following code

## Cohort Diagnostics
CohortDiagnostics::createMergedResultsFile(
  dataFolder = cohortOutputDir,
  sqliteDbPath = file.path(cohortOutputDir, "MergedCohortDiagnosticsData.sqlite"),
  overwrite = TRUE
)

CohortDiagnostics::launchDiagnosticsExplorer(
  sqliteDbPath = file.path(cohortOutputDir, "MergedCohortDiagnosticsData.sqlite"),
  makePublishable = TRUE
)
