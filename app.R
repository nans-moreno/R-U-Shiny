# =============================================================================
# APPLICATION PRINCIPALE - Orchestration POO
# =============================================================================

# Chargement des dépendances
source("requirements.R")

# Chargement des modules et classes
source("R/utils.R")
source("R/DataManager.R")
source("R/UIManager.R") 
source("R/ServerManager.R")

# =============================================================================
# INITIALISATION DES OBJETS
# =============================================================================

# Gestionnaire de données
data_manager <- DataManager$new("Projet_R_U_SHINY/data/ABBREV.csv")
data_manager$load_data()$clean_data()

# Gestionnaire d'interface
ui_manager <- UIManager$new(data_manager)

# Gestionnaire serveur  
server_manager <- ServerManager$new(data_manager)

# =============================================================================
# CRÉATION DE L'APPLICATION SHINY
# =============================================================================

# Interface utilisateur
ui <- ui_manager$create_ui()

# Logique serveur
server <- server_manager$create_server()

# =============================================================================
# LANCEMENT DE L'APPLICATION
# =============================================================================

cat("\n🚀 Lancement du Dashboard Nutritionnel Interactif\n")
cat("📊 Dataset:", nrow(data_manager$get_clean_data()), "aliments chargés\n")
cat("🎯 Application prête!\n\n")

# Démarrage de l'application
shinyApp(ui = ui, server = server)
