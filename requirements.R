# Liste des packages requis
required_packages <- c(
  # Core Shiny
  "shiny",
  "shinydashboard", 
  "shinydashboardPlus",
  "shinyWidgets",
  
  # Data manipulation
  "dplyr",
  "tidyr",
  "readr",
  "stringr",
  "lubridate",
  
  # Visualisation
  "ggplot2",
  "plotly",
  "DT",
  "scales",
  "RColorBrewer",
  "viridis",
  
  # POO
  "R6",
  
  # Utils
  "glue",
  "here",
  "magrittr"
)

# Fonction pour installer les packages manquants
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("Installation des packages manquants:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE)
  } else {
    cat("Tous les packages sont déjà installés.\n")
  }
}

# Fonction pour charger tous les packages
load_packages <- function(packages) {
  for(pkg in packages) {
    library(pkg, character.only = TRUE)
  }
  cat("Packages chargés:", paste(packages, collapse = ", "), "\n")
}

# Installation et chargement
install_if_missing(required_packages)
load_packages(required_packages)

cat("✅ Configuration des dépendances terminée.\n")