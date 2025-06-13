# =============================================================================
# UTILITIES - Fonctions utilitaires du projet
# =============================================================================

#' Fonction pour formater les nombres
#' @param x Nombre à formater
#' @param digits Nombre de décimales
format_number <- function(x, digits = 1) {
  if (is.na(x)) return("N/A")
  if (x >= 1000) {
    return(paste0(round(x / 1000, digits), "k"))
  }
  return(round(x, digits))
}

#' Palette de couleurs pour les catégories
#' @param n Nombre de couleurs nécessaires
get_color_palette <- function(n) {
  if (n <= 8) {
    return(RColorBrewer::brewer.pal(max(3, n), "Set2"))
  } else {
    return(viridis::viridis(n))
  }
}

#' Fonction pour nettoyer les noms de colonnes
clean_column_names <- function(df) {
  names(df) <- names(df) %>%
    str_replace_all("_\\(.*\\)", "") %>%
    str_replace_all("_", " ") %>%
    str_to_title()
  return(df)
}

#' Validation des données
validate_data <- function(data) {
  if (is.null(data) || nrow(data) == 0) {
    stop("❌ Données vides ou manquantes")
  }
  
  required_cols <- c("Food_Name", "Calories", "Protein_g", "Fat_g")
  missing_cols <- setdiff(required_cols, names(data))
  
  if (length(missing_cols) > 0) {
    stop(glue("❌ Colonnes manquantes: {paste(missing_cols, collapse = ', ')}"))
  }
  
  cat("✅ Validation des données réussie\n")
  return(TRUE)
}

#' Fonction pour créer des bins de calories
create_calorie_bins <- function(calories) {
  cut(calories, 
      breaks = c(0, 100, 300, 500, Inf),
      labels = c("Faible (0-100)", "Modéré (100-300)", 
                 "Élevé (300-500)", "Très Élevé (500+)"),
      include.lowest = TRUE)
}

cat("✅ Fonctions utilitaires chargées\n")
