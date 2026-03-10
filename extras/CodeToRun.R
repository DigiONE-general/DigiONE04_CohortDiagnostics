# Install Renv
install.packages("renv")

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


# [*] EDIT BELOW ==============================================================

databaseId <- "YOUR_DATABASE_ID" 
cdmDatabaseSchema <- ""
writeDatabaseSchema <- ""
tablePrefix <- "digione4_"
minCellCount <- 5
sql_dialect <- "sqlserver" #'sqlserver' - will run standard OHDSI.sql 
                           #'postgres' - will run PostgreSQL dialect
#if blank will default to OHDSI sqlserver compatible

# 1.  COHORT DIAGNOSTICS

# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = NULL, #"postgresql", "snowflake", "spark", "redshift", "sql server"
  user = NULL,
  password = NULL,
  server = NULL,
  port = NULL,
  extraSettings = NULL,
  oracleDriver = NULL,
  connectionString = NULL,
  pathToDriver = NULL,
  port = port
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

CohortDiagnostics::createMergedResultsFile(
  dataFolder = cohortOutputDir,
  sqliteDbPath = file.path(cohortOutputDir, "MergedCohortDiagnosticsData.sqlite"),
  overwrite = TRUE
)

# Launch R Shiny
CohortDiagnostics::launchDiagnosticsExplorer(
  sqliteDbPath = file.path(cohortOutputDir, "MergedCohortDiagnosticsData.sqlite"),
  makePublishable = TRUE
)
