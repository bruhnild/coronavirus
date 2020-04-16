# Coronavirus notebook

## Prérequis:
Se positionner dans le dossier du jupyter notebook:
### Créer et activer l'environnement conda :
- `conda create --name my_env python=3`
- `conda activate my_env`
### Installer les paquets suivants:
- `pip install pandas`
- `pip install xlrd`
- `pip install SQLAlchemy`
- `pip install psycopg2`

## Ce notebook permet de télécharger des jeux de données mondiaux et français :

### CoronaVirus (Covid19) - Evolution par pays et dans le monde (maj quotidienne)
- https://www.data.gouv.fr/fr/datasets/coronavirus-covid19-evolution-par-pays-et-dans-le-monde-maj-quotidienne/
### Données nationales concernant l'épidémie de COVID19 
- https://github.com/opencovid19-fr/data
### Données relatives à l'épidémie du covid-19 
- https://www.data.gouv.fr/fr/datasets/donnees-relatives-a-lepidemie-du-covid-19/
### Données hospitalières relatives à l'épidémie de COVID-19 
- https://www.data.gouv.fr/fr/datasets/donnees-hospitalieres-relatives-a-lepidemie-de-covid-19/#_
### Données relatives aux tests de dépistage de COVID-19 réalisés en laboratoire de ville
- https://www.data.gouv.fr/fr/datasets/donnees-relatives-aux-tests-de-depistage-de-covid-19-realises-en-laboratoire-de-ville
### Lieux ouverts ou fermés pendant le confinement Covid-19 
- https://www.data.gouv.fr/fr/datasets/lieux-ouverts-ou-fermes-pendant-le-confinement-covid-19/

## Commande pour exécuter exécuter le notebook
`runipy coronavirus.ipynb`

## Lancer et sauvegarder le notebook dans un nouveau notebook
`runipy coronavirus.ipynb coronavirus_output.ipynb`
