#!/bin/sh

Lancement script sql pour import et mise à jour données en base
for file in /home/mfu/Documents/Projets/coronavirus/scripts/*.sql
    do PGPASSWORD=ARZRc9pxe3hyIDY1KFMw  psql -h visu-db.makina-corpus.net -d visumarqueblanche -U visumarqueblanche -p 5432  -f $file
done

#PGPASSWORD=ARZRc9pxe3hyIDY1KFMw  psql -h visu-db.makina-corpus.net -d visumarqueblanche -U visumarqueblanche -p 5432  -f 90_createupdate_caresteouvert.sql