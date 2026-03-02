# DigiONE04: Real-World Insights on Cancer Burden and Treatment Delays – A Comprehensive Observation Study Based on DigiONE Treatment Centres (DigiACT) 

## Cohort Diagnostics

- CohortDiagnostics is an OHDSI tool which allows us to analyse and observe the coverage of our cohorts we have specified via ATLAS. See main documentation: https://ohdsi.github.io/CohortDiagnostics/

- This package contains main cohorts specific to DigiONE04 study - running this package will provide a full set of csv outputs documenting including concepts, summary statistics for cohort inclusion, index, incidence rate and more stored in a single output folder in your `cohortDiagnosticsResults` directory. These can be reviewed to assess 'missing' concepts from the cohort definitions or any inclusions which are incorrect/ unexpected.

- CohortDiagnostics results show cohort inclusion rule attrition, orphan codes (concepts which should be included in the cohort but are not included) and cohort overlap which are key in shaping cohort definition for DigiONE studies.

-   This package also uses Rshiny to generate a dashboard interface from .sqlite file. This is generated at the end of `CodeToRun.R` - after running and generating results once you can use the View Results chunk at the end of CodeToRun.R to regenerate the results dashboard as you require. 

*Requirements and run time*

Run time: system dependant - allow approx 60 - 75 minutes

Requirements: Requires R, some packages require Java (see here: https://ohdsi.github.io/Hades/rSetup.html)
              Allow up to 500MB disk space 


*Running the code in RStudio*

Note: Make sure you open the folder as an R Project in order to allow renv functionality.

- Open `CodeToRun.R` script in /extras/ folder.

-   Install the latest version of renv (as per first few lines of script)

``` r
install.packages("renv")
```

-   Restore the project library (as per first few lines of script)

``` r
renv::restore()
```

-   Edit the variables in the `CodeToRun.R` script where indicated to 'Edit Below' - these are used to connect to the database to the correct values for your environment.
-   Execute the `CodeToRun.R` script in RStudio. The 'View Results' chunk of the script is optional, but recommended to allow interactive exploration of the results. 


------------------------------------------------------------------------


