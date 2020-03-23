--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Intégration csv politologue en base
TRUNCATE TABLE sante.coronapolitologue;

\COPY sante.coronapolitologue(date_actualisation, country_region, confirmed, deaths, recovered, rate_deaths, rate_recovered, rate_confirmed) FROM '/home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/data/sources_traitees/coronapolitologue.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : opencovid19fr
--- Traitement : Intégration csv opencovid19 france en base
TRUNCATE TABLE sante.opencovid19fr;

\COPY sante.opencovid19fr(date_actualisation, granularite, maille_code, maille_nom, confirmes, deces, reanimation, hospitalises, gueris, source_nom, source_url, source_type) FROM '/home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/data/sources_traitees/opencovid19fr.csv' DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep
--- Traitement : Intégration csv sursaud_covid19_quotidien niveau departemental en base
TRUNCATE TABLE sante.sursaud_covid19_quotidien_dep;

\COPY sante.sursaud_covid19_quotidien_dep(code_dep, date_actualisation, sursaud_cl_age_corona,nbre_pass_corona,nbre_pass_tot,nbre_hospit_corona,nbre_pass_corona_h, nbre_pass_corona_f, nbre_pass_tot_h,nbre_pass_tot_f,nbre_hospit_corona_h,nbre_hospit_corona_f,nbre_acte_corona,nbre_acte_tot,nbre_acte_corona_h,nbre_acte_corona_f,nbre_acte_tot_h,nbre_acte_tot_f) FROM '/home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/data/sources_traitees/sursaud-covid19-quotidien_dep.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep
--- Traitement : Intégration csv sursaud_covid19_quotidien niveau departemental en base
TRUNCATE TABLE sante.sursaud_covid19_quotidien_reg;

\COPY sante.sursaud_covid19_quotidien_reg(code_reg, date_actualisation, sursaud_cl_age_corona,nbre_pass_corona,nbre_pass_tot,nbre_hospit_corona,nbre_pass_corona_h, nbre_pass_corona_f, nbre_pass_tot_h,nbre_pass_tot_f,nbre_hospit_corona_h,nbre_hospit_corona_f,nbre_acte_corona,nbre_acte_tot,nbre_acte_corona_h,nbre_acte_corona_f,nbre_acte_tot_h,nbre_acte_tot_f) FROM '/home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/data/sources_traitees/sursaud-covid19-quotidien_reg.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

