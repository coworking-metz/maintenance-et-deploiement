## Backups `backup.sh`

### Description
Ce script `backup.sh` est conçu pour effectuer des sauvegardes complètes d'un site spécifique, incluant à la fois les fichiers du site et sa base de données. Il est adapté pour un environnement WordPress mais peut être modifié pour d'autres usages en modifiant les paremètres d'appel...

### Prérequis
- Bash
- MySQL avec accès à la base de données
- Zip pour la compression des fichiers
- Rclone configuré pour la synchronisation avec un stockage S3
- Un dossier data hébergeant les assets, qui n'est pas présent dans l'arbo du site

### Utilisation
Pour utiliser ce script, lancez-le avec les paramètres suivants :

```
/home/coworking/scripts/backup.sh --site_name=nom_du_site --site_path=/chemin/vers/le/site --backup_path=/chemin/vers/les/sauvegardes --data_path=/chemin/vers/les/donnees --database_name=nom_de_la_base
```
Il peut être ajouté tel quel en crontab

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
