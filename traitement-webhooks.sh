#!/bin/bash

date
# Ce script récupère les clés de Redis commençant par 'webhook-deploy' créées par /home/coworking/webhooks, 
# puis lance un script pour chaque clé trouvée en utilisant la valeur associée comme argument, 
# puis supprime la clé de Redis après son utilisation.

# Récupère les clés de Redis commençant par 'webhook-deploy'
keys=$(redis-cli KEYS "webhook-deploy*")

for key in $keys; do
  # Récupère la valeur pour chaque clé
  VALUE=$(redis-cli GET "$key")
  redis-cli DEL "$key" > /dev/null
  # Lance le script avec la valeur en argument
  /home/coworking/scripts/deploy.sh --site="$VALUE" --force
done

# Récupère les clés de Redis commençant par 'webhook-cloudflare'
#!/bin/bash

# Search for the 'webhook-cloudflare' key in local Redis
KEY_CF=$(redis-cli exists webhook-cloudflare-purge)

# Check if the key exists. If it does, KEY_CF will be 1; otherwise, 0.
if [ "$KEY_CF" -eq 1 ]; then
    # Launch the script if the key exists
    /home/coworking/scripts/cloudflare.sh 

    # Delete the key after executing the script
    redis-cli del webhook-cloudflare-purge > /dev/null

fi


echo "Traitement des webhooks terminé"