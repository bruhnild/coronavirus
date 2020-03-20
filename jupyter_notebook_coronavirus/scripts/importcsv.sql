--- Schema : sante
--- Table : coronavirus
--- Traitement : Intégration csv monde en base

\COPY sante.coronavirus(date_actualisation, country_region, confirmed, deaths, recovered, rate_deaths, rate_recovered, rate_confirmed) FROM '/home/mfu/Documents/coronavirus/jupyter_notebook_coronavirus/data/corona.csv' DELIMITER ';' CSV HEADER encoding 'utf8' null '';

--- Schema : sante
--- Table : coronavirus
--- Traitement : Intégration csv france en base

\COPY sante.coronavirus_france(date_actualisation, granularite, maille_code, maille_nom, confirmes, deces, reanimation, source_nom, source_url, source_type) FROM '/home/mfu/Documents/coronavirus/jupyter_notebook_coronavirus/data/coronacsvfrance.csv' DELIMITER ',' CSV HEADER encoding 'utf8' null '';
