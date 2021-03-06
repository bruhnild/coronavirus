--- Schema : sante
--- Table : coronapolitologue
--- Traitement : Intégration csv politologue en base
TRUNCATE TABLE sante.coronapolitologue;

\COPY sante.coronapolitologue(date_actualisation, country_region, confirmed, deaths, recovered, rate_deaths, rate_recovered, rate_confirmed) FROM '/home/mfu/Documents/Projets/coronavirus//data/sources_traitees/coronapolitologue.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : opencovid19fr
--- Traitement : Intégration csv opencovid19 france en base
TRUNCATE TABLE sante.opencovid19fr;

\COPY sante.opencovid19fr(date_actualisation, granularite, maille_code, maille_nom, confirmes, cas_ehpad, confirmes_ehpad, cas_possibles_ehpad, deces, deces_ehpad, reanimation, hospitalises, gueris, depistes, source_nom, source_url, source_archive, source_type) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/opencovid19fr.csv' DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep
--- Traitement : Intégration csv sursaud_covid19_quotidien niveau departemental en base
TRUNCATE TABLE sante.sursaud_covid19_quotidien_dep;

\COPY sante.sursaud_covid19_quotidien_dep(code_dep, date_actualisation, sursaud_cl_age_corona,nbre_pass_corona,nbre_pass_tot,nbre_hospit_corona,nbre_pass_corona_h, nbre_pass_corona_f, nbre_pass_tot_h,nbre_pass_tot_f,nbre_hospit_corona_h,nbre_hospit_corona_f,nbre_acte_corona,nbre_acte_tot,nbre_acte_corona_h,nbre_acte_corona_f,nbre_acte_tot_h,nbre_acte_tot_f) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/sursaud-covid19-quotidien_dep.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : sursaud_covid19_quotidien_dep
--- Traitement : Intégration csv sursaud_covid19_quotidien niveau departemental en base
TRUNCATE TABLE sante.sursaud_covid19_quotidien_reg;

\COPY sante.sursaud_covid19_quotidien_reg(code_reg, date_actualisation, sursaud_cl_age_corona,nbre_pass_corona,nbre_pass_tot,nbre_hospit_corona,nbre_pass_corona_h, nbre_pass_corona_f, nbre_pass_tot_h,nbre_pass_tot_f,nbre_hospit_corona_h,nbre_hospit_corona_f,nbre_acte_corona,nbre_acte_tot,nbre_acte_corona_h,nbre_acte_corona_f,nbre_acte_tot_h,nbre_acte_tot_f) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/sursaud-covid19-quotidien_reg.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Intégration csv donnees-hospitalieres-covid19 niveau departemental en base
TRUNCATE TABLE sante.donneeshospitalierescovid19;

\COPY sante.donneeshospitalierescovid19(dep, sexe, jour,hosp,rea,rad,dc) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/donnees-hospitalieres-covid19.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : donneeshospitalierescovid19
--- Traitement : Intégration csv donnees-hospitalieres-etablissements-covid19 niveau departemental en base
TRUNCATE TABLE sante.donneeshospitalieresetablissementscovid19;

\COPY sante.donneeshospitalieresetablissementscovid19(dep, jour, nb) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/donnees-hospitalieres-etablissements-covid19.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : donneestestscovid19laboquotidien
--- Traitement : Intégration csv donnees-tests-covid19-labo-quotidien en base
TRUNCATE TABLE sante.donneestestscovid19laboquotidien;

\COPY sante.donneestestscovid19laboquotidien(dep, jour, clage_covid, nb_test, nb_pos, nb_test_h, nb_pos_h, nb_test_f, nb_pos_f) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/donnees-tests-covid19-labo-quotidien.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : transfertspatientscovid19
--- Traitement : Intégration csv transfertspatientscovid19 en base
TRUNCATE TABLE sante.transfertspatientscovid19;

\COPY sante.transfertspatientscovid19(debut_transfert, fin_transfert, type_vecteur, region_depart, region_arrivee, pays_arrivee, nombre_patients_transferes) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/transferts-patients-covid19.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : niveauxexcesmortalitecovid19dep
--- Traitement : Intégration csv niveauxexcesmortalitecovid19dep en base
TRUNCATE TABLE sante.niveauxexcesmortalitecovid19dep;

\COPY sante.niveauxexcesmortalitecovid19dep(dep, an_sem, clave_covid_dc65, cat_zscore) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/niveaux-exces-mortalite-covid19-dep.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

--- Schema : sante
--- Table : niveauxexcesmortalitecovid19reg
--- Traitement : Intégration csv niveauxexcesmortalitecovid19reg en base
TRUNCATE TABLE sante.niveauxexcesmortalitecovid19reg;

\COPY sante.niveauxexcesmortalitecovid19reg(reg, an_sem, clave_covid_dc65, cat_zscore) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/niveaux-exces-mortalite-covid19-reg.csv'DELIMITER ';' CSV HEADER ENCODING 'utf8' NULL '';

