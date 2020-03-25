#!/bin/sh

# Lancement script sql pour import csv en base
PGPASSWORD=ARZRc9pxe3hyIDY1KFMw psql -h visu-db.makina-corpus.net -d visumarqueblanche -U visumarqueblanche -p 5432  -f /home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/scripts/importcsv.sql

# Lancement script sql préparation des données en base
PGPASSWORD=ARZRc9pxe3hyIDY1KFMw psql -h visu-db.makina-corpus.net -d visumarqueblanche -U visumarqueblanche -p 5432  -f /home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/scripts/updatetables.sql

