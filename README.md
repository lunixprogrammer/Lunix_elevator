# 🛗 lunix_elevator — Elevator Builder for FiveM (QBX)

> **FR** — Script de création et gestion d'ascenseurs dynamiques pour serveurs FiveM sous framework QBX.  
> **EN** — Dynamic elevator creation and management script for FiveM servers running the QBX framework.

---

## 📋 Sommaire / Table of Contents

- [FR — Présentation](#-présentation)
- [EN — Overview](#-overview)
- [Dépendances / Dependencies](#-dépendances--dependencies)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Commandes / Commands](#-commandes--commands)
- [Aperçu / Preview](#-aperçu--preview)

---

## 🇫🇷 Présentation

**lunix_elevator** permet aux administrateurs de créer des ascenseurs dynamiques en jeu, directement depuis le serveur FiveM, sans modifier de fichier de configuration. Les ascenseurs sont sauvegardés en base de données et rechargés automatiquement au redémarrage.

### Fonctionnalités
- ✅ Création d'ascenseurs en jeu via commande admin
- ✅ Nombre d'étages illimité par ascenseur
- ✅ Restriction par job (ex: réservé à la `police`)
- ✅ Interface NUI moderne (panneau de boutons style ascenseur)
- ✅ Fondu noir pendant le trajet
- ✅ Son d'arrivée natif GTA V
- ✅ Compatible `ox_target` ou `TextUI`
- ✅ Sauvegarde en base de données MySQL
- ✅ Menu admin complet (ajout, édition, suppression d'étages)

---

## 🇬🇧 Overview

**lunix_elevator** allows server administrators to create dynamic elevators in-game, directly from within FiveM, without editing any config files. Elevators are saved to a database and automatically reloaded on server restart.

### Features
- ✅ In-game elevator creation via admin command
- ✅ Unlimited floors per elevator
- ✅ Job restriction support (e.g. `police` only)
- ✅ Modern NUI interface (elevator button panel)
- ✅ Screen fade during travel
- ✅ Native GTA V arrival sound
- ✅ Compatible with `ox_target` or `TextUI`
- ✅ MySQL database saving
- ✅ Full admin menu (add, edit, delete floors)

---

## 📦 Dépendances / Dependencies

| Ressource | Lien / Link |
|-----------|-------------|
| `qbx_core` | [github.com/Qbox-project/qbx_core](https://github.com/Qbox-project/qbx_core) |
| `ox_lib` | [github.com/overextended/ox_lib](https://github.com/overextended/ox_lib) |
| `oxmysql` | [github.com/overextended/oxmysql](https://github.com/overextended/oxmysql) |
| `ox_target` *(optionnel/optional)* | [github.com/overextended/ox_target](https://github.com/overextended/ox_target) |

---

## 🚀 Installation

**FR**
1. Téléchargez le script et placez le dossier dans votre répertoire `resources/`
2. Assurez-vous d'avoir les dépendances installées et démarrées avant `lunix_elevator` :
    - `qbx_core`, `ox_lib`, `oxmysql` (et `ox_target` si vous l'utilisez)
3. Ajoutez `ensure lunix_elevator` dans votre `server.cfg` après les dépendances
3. Démarrez le serveur — la table SQL est créée automatiquement
4. Configurez le fichier `config.lua` selon vos besoins

> ⚠️ Exemple ACE pour autoriser la création via commande (optionnel) dans `server.cfg` :
>
> ```
> add_ace group.admin command.createelevator allow
> add_principal identifier.steam:0123456789abcdef group.admin
> ```

**EN**
1. Download and place the folder into your `resources/` directory
2. Add `ensure lunix_elevator` to your `server.cfg`
3. Start the server — the SQL table is created automatically
4. Edit `config.lua` to match your needs

> ⚠️ **FR** Aucune importation SQL manuelle requise.  
> ⚠️ **EN** No manual SQL import required.

### Notes importantes
- Le resource suppose l'existence de `exports.qbx_core:GetPlayerData()` côté client et `exports.qbx_core:GetPlayer(source)` côté serveur. Si votre framework utilise des noms différents, adaptez les appels correspondants dans `client.lua` et `server.lua`.
- L'UI NUI n'utilise plus de fichier audio local par défaut (le son d'arrivée est joué côté client via la native GTA V). Si vous souhaitez un son NUI personnalisé, ajoutez `html/elevator_ding.mp3` et mettez à jour `fxmanifest.lua` pour l'inclure.

---

## ⚙️ Configuration

Fichier / File : `config.lua`

```lua
Config = {}

-- FR: Groupes ayant les droits admin | EN: Groups with admin rights
Config.AdminGroups = { 'admin', 'god' }

-- FR: Utiliser ox_target (true) ou TextUI/Points (false)
-- EN: Use ox_target (true) or TextUI/Points (false)
Config.UseTarget = false

-- FR: Jouer le son d'arrivée | EN: Play arrival sound
Config.ElevatorSound = true

-- FR: Fondu noir pendant le trajet | EN: Screen fade during travel
Config.ScreenFade = true

-- FR: Durée du trajet en millisecondes | EN: Travel duration in milliseconds
Config.TravelTime = 2000

-- FR: Traductions | EN: Translations
Config.Locales = {
    open_elevator    = "Appeler l'ascenseur",   -- Button label to open elevator
    create_elevator  = "Créer un ascenseur",    -- Dialog title for creation
    elevator_created = "Ascenseur créé",        -- Success notification
    elevator_error   = "Erreur lors de la création",
    invalid_permissions = "Permission refusée",
    floor_name       = "Étage %s",
    delete_elevator  = "Supprimer l'ascenseur",
    elevator_deleted = "Ascenseur supprimé"
}
```

### 🌍 Exemple multilingue / Multilingual example

**Anglais / English**
```lua
Config.Locales = {
    open_elevator       = "Call elevator",
    create_elevator     = "Create elevator",
    elevator_created    = "Elevator created successfully",
    elevator_error      = "Error during creation",
    invalid_permissions = "You don't have permission",
    floor_name          = "Floor %s",
    delete_elevator     = "Delete elevator",
    elevator_deleted    = "Elevator deleted"
}
```

**Espagnol / Spanish**
```lua
Config.Locales = {
    open_elevator       = "Llamar al ascensor",
    create_elevator     = "Crear ascensor",
    elevator_created    = "Ascensor creado con éxito",
    elevator_error      = "Error al crear",
    invalid_permissions = "No tienes permiso",
    floor_name          = "Piso %s",
    delete_elevator     = "Eliminar ascensor",
    elevator_deleted    = "Ascensor eliminado"
}
```

**Allemand / German**
```lua
Config.Locales = {
    open_elevator       = "Aufzug rufen",
    create_elevator     = "Aufzug erstellen",
    elevator_created    = "Aufzug erfolgreich erstellt",
    elevator_error      = "Fehler beim Erstellen",
    invalid_permissions = "Keine Berechtigung",
    floor_name          = "Etage %s",
    delete_elevator     = "Aufzug löschen",
    elevator_deleted    = "Aufzug gelöscht"
}
```

---

## 💬 Commandes / Commands

| Commande / Command | Permission | Description FR | Description EN |
|--------------------|------------|----------------|----------------|
| `/createelevator` | Admin | Créer un nouvel ascenseur en jeu | Create a new elevator in-game |
| `/listelevators` | Admin | Gérer les ascenseurs existants | Manage existing elevators |

> **FR** Les permissions sont vérifiées via les groupes QBX définis dans `Config.AdminGroups` ou via les ACE (`command.createelevator`).  
> **EN** Permissions are checked via QBX groups defined in `Config.AdminGroups` or via ACE (`command.createelevator`).

---

## 🗄️ Base de données / Database

La table suivante est créée automatiquement / The following table is created automatically:

```sql
CREATE TABLE IF NOT EXISTS `elevators` (
    `id`     INT(11) NOT NULL AUTO_INCREMENT,
    `name`   VARCHAR(50) DEFAULT NULL,
    `job`    VARCHAR(50) DEFAULT 'none',
    `floors` LONGTEXT DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 👤 Auteur / Author

**Umit Koysuren** — [LuSh. Team]  
Script développé pour serveurs FiveM QBX / Developed for QBX FiveM servers.

---

## 📄 Licence / License

FR — Ce script est fourni tel quel, à usage privé. Toute revente est interdite.  
EN — This script is provided as-is, for private use only. Reselling is prohibited.
