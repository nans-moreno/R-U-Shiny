# =============================================================================
# UI MANAGER - Classe pour la gestion de l'interface utilisateur
# =============================================================================

UIManager <- R6Class(
  "UIManager",
  
  # === PROPRIÉTÉS PRIVÉES ===
  private = list(
    .data_manager = NULL
  ),
  
  # === PROPRIÉTÉS PUBLIQUES ===
  public = list(
    
    #' Initialisation
    #' @param data_manager Instance de DataManager
    initialize = function(data_manager) {
      private$.data_manager <- data_manager
      cat("🎨 UIManager initialisé\n")
    },
    
    #' Création de la barre latérale avec filtres
    create_sidebar = function() {
      dashboardSidebar(
        sidebarMenu(
          menuItem("📊 Vue d'ensemble", tabName = "overview", icon = icon("chart-bar")),
          menuItem("🔍 Analyse Détaillée", tabName = "analysis", icon = icon("search")),
          menuItem("🥗 Comparateur", tabName = "compare", icon = icon("balance-scale"))
        ),
        
        br(),
        div(class = "sidebar-section",
          h4("🎛️ Filtres", style = "color: white; text-align: center;"),
          
          # Sélection de catégorie
          selectInput(
            "category", 
            "Catégorie d'aliments:",
            choices = private$.data_manager$get_category_choices(),
            selected = "all"
          ),
          
          # Plage de calories
          sliderInput(
            "calories_range",
            "Plage de calories:",
            min = 0, max = 1000, 
            value = c(0, 500),
            step = 10
          ),
          
          # Niveau de protéines
          sliderInput(
            "protein_range",
            "Protéines (g):",
            min = 0, max = 100,
            value = c(0, 50)
          ),
          
          # Recherche par nom
          textInput(
            "search", 
            "Rechercher un aliment:", 
            placeholder = "Ex: cheese, apple..."
          ),
          
          br(),
          div(style = "text-align: center;",
              actionButton("reset_filters", "🔄 Réinitialiser", 
                          class = "btn-warning btn-sm")
          )
        )
      )
    },
    
    #' Création de l'en-tête
    create_header = function() {
      dashboardHeader(
        title = tags$span(
          icon("utensils", style = "margin-right: 10px;"),
          "Dashboard Nutritionnel Interactif",
          style = "font-size: 18px; font-weight: bold;"
        )
      )
    },
    
    #' Création du corps principal
    create_body = function() {
      dashboardBody(
        # CSS personnalisé
        tags$head(
          tags$style(HTML("
            .sidebar-section { padding: 15px; }
            .value-box-icon { font-size: 60px !important; }
            .small-box h3 { font-size: 2.2rem !important; }
            .content-wrapper { background: #f4f4f4; }
          "))
        ),
        
        tabItems(
          # ONGLET 1: VUE D'ENSEMBLE
          tabItem(
            tabName = "overview",
            source("R/modules/overview_module.R", local = TRUE)$value
          ),
          
          # ONGLET 2: ANALYSE DÉTAILLÉE  
          tabItem(
            tabName = "analysis",
            source("R/modules/analysis_module.R", local = TRUE)$value
          ),
          
          # ONGLET 3: COMPARATEUR
          tabItem(
            tabName = "compare", 
            source("R/modules/comparison_module.R", local = TRUE)$value
          )
        )
      )
    },
    
    #' Création de l'UI complète
    create_ui = function() {
      dashboardPage(
        header = self$create_header(),
        sidebar = self$create_sidebar(),
        body = self$create_body(),
        skin = "blue"
      )
    }
  )
)

cat("✅ Classe UIManager créée\n")
