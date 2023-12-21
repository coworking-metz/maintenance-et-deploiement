## Backups `backups.sh`

### Description
Ce script `backup.sh` est conçu pour effectuer des sauvegardes complètes d'un site spécifique, incluant à la fois les fichiers du site et sa base de données. Il est adapté pour un environnement WordPress mais peut être modifié pour d'autres usages.

### Prérequis
- Bash
- MySQL avec accès à la base de données
- Zip pour la compression des fichiers
- Rclone configuré pour la synchronisation avec un stockage S3

### Utilisation
Pour utiliser ce script, lancez-le avec les paramètres suivants :

```
/home/coworking/scripts/backup.sh --site_name=nom_du_site --site_path=/chemin/vers/le/site --backup_path=/chemin/vers/les/sauvegardes --data-path=/chemin/vers/les/donnees --database_name=nom_de_la_base
```

### Paramètres
- `--site_name`: Nom du site pour identifier les sauvegardes.
- `--site_path`: Chemin absolu vers le répertoire du site.
- `--backup_path`: Chemin où les sauvegardes seront stockées.
- `--data_path`: Chemin pour les données supplémentaires à sauvegarder, comme les assets uploadés dans wordpress par exemple. Ces données ne sont pas versionnée: une synhro de tout le dossier est faite vers s3
- `--database_name`: Nom de la base de données à sauvegarder.

### Fonctionnalités
- **Sauvegarde de la base de données MySQL** : Exporte et compresse la base de données.
- **Sauvegarde des fichiers du site** : Compresse le dossier du site en excluant les fichiers inutiles (comme .git).
- **Rotation des sauvegardes** : Supprime automatiquement les anciens fichiers de sauvegarde pour économiser de l'espace.
- **Synchronisation avec S3** : Synchronise les sauvegardes vers un bucket S3 pour une sécurité accrue.

### Rotation des sauvegardes
- Les sauvegardes MySQL sont supprimées après 30 jours.
- Les sauvegardes du site sont supprimées après 15 jours.

### Notifications
Le script affiche des messages de progression et confirme la fin des opérations de sauvegarde et de rotation.

### Sécurité
Assurez-vous que l'utilisateur exécutant le script a les permissions nécessaires pour accéder et modifier les fichiers et bases de données concernés. Utilisez des mécanismes de sécurité pour protéger les informations d'identification.

### Support
Pour toute question ou problème, veuillez vérifier le code source et contacter votre administrateur système.
