# =============================================================================
# DATA MANAGER - Classe pour la gestion des données
# =============================================================================

#' Classe R6 pour gérer les données nutritionnelles
#' 
#' Cette classe encapsule toutes les opérations liées aux données :
#' - Chargement
#' - Nettoyage  
#' - Transformation
#' - Filtrage
DataManager <- R6Class(
  "DataManager",
  
  # === PROPRIÉTÉS PRIVÉES ===
  private = list(
    .raw_data = NULL,
    .clean_data = NULL,
    .file_path = NULL
  ),
  
  # === PROPRIÉTÉS PUBLIQUES ===
  public = list(
    
    #' Initialisation de la classe
    #' @param file_path Chemin vers le fichier de données
    initialize = function(file_path = "data/ABBREV.csv") {
      private$.file_path <- file_path
      cat("🔧 DataManager initialisé\n")
    },
    
    #' Chargement des données brutes
    load_data = function() {
      if (!file.exists(private$.file_path)) {
        stop(glue("❌ Fichier introuvable: {private$.file_path}"))
      }
      tryCatch({
        cat("📥 Chargement des données depuis:", private$.file_path, "\n")
        private$.raw_data <- read_csv(private$.file_path, show_col_types = FALSE)
        cat("✅ Données chargées:", nrow(private$.raw_data), "lignes\n")
        return(self)
      }, error = function(e) {
        stop(glue("❌ Erreur lors du chargement: {e$message}"))
      })
    },
    
    #' Nettoyage et transformation des données
    clean_data = function() {
      if (is.null(private$.raw_data)) {
        stop("❌ Veuillez d'abord charger les données avec load_data()")
      }
      
      cat("🧹 Nettoyage des données en cours...\n")
      
      private$.clean_data <- private$.raw_data %>%
        # Renommage des colonnes principales
        rename(
          Food_ID = index,
          Food_Name = Shrt_Desc,
          Water_g = `Water_(g)`,
          Calories = Energ_Kcal,
          Protein_g = `Protein_(g)`,
          Fat_g = `Lipid_Tot_(g)`,
          Carbs_g = `Carbohydrt_(g)`,
          Fiber_g = `Fiber_TD_(g)`,
          Sugar_g = `Sugar_Tot_(g)`,
          Calcium_mg = `Calcium_(mg)`,
          Iron_mg = `Iron_(mg)`,
          VitC_mg = `Vit_C_(mg)`
        ) %>%
        # Suppression des valeurs manquantes critiques
        filter(
          !is.na(Calories), 
          !is.na(Protein_g), 
          !is.na(Fat_g),
          Calories > 0
        ) %>%
        # Création de catégories alimentaires
        mutate(
          Food_Category = case_when(
            str_detect(Food_Name, "MILK|CHEESE|BUTTER|CREAM|YOGURT") ~ "Produits Laitiers",
            str_detect(Food_Name, "MEAT|BEEF|PORK|CHICKEN|TURKEY") ~ "Viandes",
            str_detect(Food_Name, "FISH|SALMON|TUNA") ~ "Poissons",
            str_detect(Food_Name, "FRUIT|APPLE|BANANA|ORANGE") ~ "Fruits",
            str_detect(Food_Name, "VEG|CARROT|POTATO|TOMATO") ~ "Légumes",
            str_detect(Food_Name, "BREAD|CEREAL|RICE|PASTA") ~ "Céréales",
            str_detect(Food_Name, "OIL|FAT") ~ "Matières Grasses",
            TRUE ~ "Autres"
          ),
          # Niveaux de calories
          Calorie_Level = create_calorie_bins(Calories),
          # Ratios nutritionnels
          Protein_Ratio = round((Protein_g * 4 / Calories) * 100, 1),
          Fat_Ratio = round((Fat_g * 9 / Calories) * 100, 1),
          Carbs_Ratio = round((Carbs_g * 4 / Calories) * 100, 1)
        ) %>%
        # Nettoyage des noms d'aliments
        mutate(
          Food_Name = str_to_title(str_replace_all(Food_Name, ",", " -"))
        )
      
      # Validation
      validate_data(private$.clean_data)
      
      cat("✅ Nettoyage terminé:", nrow(private$.clean_data), "lignes conservées\n")
      return(self)
    },
    
    #' Obtenir les données nettoyées
    get_clean_data = function() {
      if (is.null(private$.clean_data)) {
        stop("❌ Veuillez d'abord nettoyer les données avec clean_data()")
      }
      return(private$.clean_data)
    },
    
    #' Filtrage des données selon critères
    #' @param category Catégorie alimentaire
    #' @param calorie_range Plage de calories [min, max]
    #' @param protein_range Plage de protéines [min, max] 
    #' @param search_term Terme de recherche
    filter_data = function(category = "all", 
                          calorie_range = c(0, 1000),
                          protein_range = c(0, 100),
                          search_term = "") {
      
      data_filtered <- private$.clean_data
      
      # Filtre par catégorie
      if (category != "all") {
        data_filtered <- data_filtered %>%
          filter(Food_Category == category)
      }
      
      # Filtre par calories
      data_filtered <- data_filtered %>%
        filter(Calories >= calorie_range[1] & Calories <= calorie_range[2])
      
      # Filtre par protéines
      data_filtered <- data_filtered %>%
        filter(Protein_g >= protein_range[1] & Protein_g <= protein_range[2])
      
      # Filtre par recherche
      if (search_term != "") {
        data_filtered <- data_filtered %>%
          filter(str_detect(str_to_lower(Food_Name), str_to_lower(search_term)))
      }
      
      return(data_filtered)
    },
    
    #' Obtenir les statistiques résumées
    get_summary_stats = function() {
      data <- self$get_clean_data()
      
      return(list(
        total_foods = nrow(data),
        avg_calories = round(mean(data$Calories, na.rm = TRUE), 1),
        max_protein = round(max(data$Protein_g, na.rm = TRUE), 1),
        categories = length(unique(data$Food_Category))
      ))
    },
    
    #' Obtenir les choix pour les widgets
    get_category_choices = function() {
      categories <- unique(self$get_clean_data()$Food_Category)
      choices <- setNames(categories, categories)
      return(c("Toutes" = "all", choices))
    }
  )
)

cat("✅ Classe DataManager créée\n")
