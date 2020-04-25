<h1 align="center">
  Coronavirus notebooks
</h1>

## Pour commencer
### Prérequis

Pour travailler sur ce projet il faut installer:

- python 3
- conda
- jupyter notebook

Se positionner à la racine du projet :
- créer et activer un environnement conda :

```sh
$ conda create --name my_env python=3
$ conda activate my_env
```
- installer les paquets suivants :

```sh
$ pip install pandas
$ pip install xlrd
$ pip install SQLAlchemy
$ pip install psycopg2
$ pip install Shapely
$ pip install geopandas
```
## Ces notebooks permettent de télécharger et exploiter les jeux de données suivants:

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

## Lignes de commande pour exécuter les notebooks
### avec l'interface jupyter notebook
```sh
$ jupyter notebook
```
### avec runpy
```sh
$ runipy coronavirus.ipynb
```
```sh
$ runipy caresteouvert.ipynb
```