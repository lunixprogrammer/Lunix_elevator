Config = {}

Config.AdminGroups = { 'admin', 'god' } -- Groupes Qbox/Ox

Config.UseTarget = false -- Utiliser ox_target (true) ou TextUI/Points (false)

Config.ElevatorSound = true -- Jouer le son
Config.ScreenFade = true -- Fondu noir pendant le trajet
Config.TravelTime = 2000 -- Temps de trajet en ms (doit être synchro avec le son environ)

-- Traductions
Config.Locales = {
    open_elevator = "Appeler l'ascenseur",
    create_elevator = "Créer un ascenseur",
    elevator_created = "Ascenseur créé avec succès",
    elevator_error = "Erreur lors de la création",
    invalid_permissions = "Vous n'avez pas la permission",
    floor_name = "Étage %s",
    delete_elevator = "Supprimer l'ascenseur",
    elevator_deleted = "Ascenseur supprimé"
}
