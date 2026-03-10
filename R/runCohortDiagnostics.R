ParallelLogger::addDefaultFileLogger(file.path(cohortOutputDir, "log.txt"))
ParallelLogger::addDefaultErrorReportLogger(file.path(cohortOutputDir, "errorReportR.txt"))

SQL_DIR_MAPPING <- list(
  postgres = "postgresql",
  postgresql = "postgresql",
  sqlserver = "sql_server"
)

# generate cohorts ----
ParallelLogger::logInfo("Creating cohorts")
cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTable)

CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortTableNames = cohortTableNames,
  cohortDatabaseSchema = writeDatabaseSchema,
  incremental = FALSE
)

# Default sql_dialect to sqlserver
if (is.null(sql_dialect) || sql_dialect == "") {
  sql_dialect <- "sqlserver"
}
message("Using SQL dialect ", sql_dialect, " in ", here::here("inst", "sql", SQL_DIR_MAPPING[[sql_dialect]]))

cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = here::here("inst", "cohortsToCreate.csv"),
  jsonFolder = here::here("inst", "cohorts"),
  sqlFolder = here::here("inst", "sql", SQL_DIR_MAPPING[[sql_dialect]]),
  cohortFileNameValue = "cohortName"
  
)

CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = writeDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = cohortDefinitionSet
)

CohortGenerator::exportCohortStatsTables(
  connectionDetails = connectionDetails,
  cohortDefinitionSet = cohortDefinitionSet,
  cohortDatabaseSchema = writeDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortStatisticsFolder = cohortOutputDir
)

# run diagnostics ----
temporalCovariateSettings <- FeatureExtraction::createTemporalCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useDemographicsAgeGroup = TRUE,
  useDemographicsIndexYear = TRUE,
  useDemographicsIndexMonth = TRUE,
  useDemographicsIndexYearMonth = TRUE,
  useDemographicsPriorObservationTime = TRUE,
  useDemographicsPostObservationTime = TRUE,
  useDemographicsTimeInCohort = TRUE,
  useConditionOccurrence = TRUE,
  useProcedureOccurrence = FALSE,
  useDrugEraStart = TRUE,
  useMeasurement = TRUE,
  useDrugExposure = TRUE,
  temporalStartDays = CohortDiagnostics::getDefaultCovariateSettings()$temporalStartDays,
  temporalEndDays =  CohortDiagnostics::getDefaultCovariateSettings()$temporalEndDays
)

CohortDiagnostics::executeDiagnostics(
  cohortDefinitionSet = cohortDefinitionSet,
  exportFolder = cohortOutputDir,
  databaseId = databaseId,
  cohortDatabaseSchema = writeDatabaseSchema,
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  tempEmulationSchema = tempEmulationSchema,
  cohortTable = cohortTable,
  cohortTableNames = cohortTableNames,
  vocabularyDatabaseSchema = cdmDatabaseSchema,
  cdmVersion = 5,
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = TRUE,
  runVisitContext = FALSE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  temporalCovariateSettings = temporalCovariateSettings,
  minCellCount = minCellCount
)

ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE)
ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE)
