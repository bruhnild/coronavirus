
-- -------------------------------------------------------------------------------------
-- Auteur : Marine FAUCHER (MAKINA CORPUS)
-- Date de création : 25/03/2020
-- Objet : Préparation des données ça reste ouvert
-- Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-- -------------------------------------------------------------------------------------


--  -- Schema : sante
-- -- Table : caresteouvert
-- -- Traitement : Création table

 
--    DROP TABLE IF EXISTS sante.caresteouvert;
--     CREATE TABLE sante.caresteouvert (
--     gid serial , -- Identifiant unique
--     name character varying(255) DEFAULT 'Non connu' , -- Nom du lieu
--     cat character varying(255) DEFAULT 'Non connu' , -- Categories OSM
--     brand character varying(255) DEFAULT 'Non connu' , -- Nom de l'enseigne/réseau
--     wikidata character varying(255) DEFAULT 'Non connu' , -- Identifiant Wikidata associé à l'enseigne
--     url_hours text DEFAULT 'Non connu' , -- Lien URL vers lequel les horaires des commerces de l'enseigne associée sont renseignées
--     infos text DEFAULT 'Non connu' , -- Texte libre pour donner plus de détails sur les conditions d'accès
--     status character varying(255) DEFAULT 'Non connu', -- État d'ouverture ou fermeture
--     opening_hours character varying(255) DEFAULT 'Non connu', -- Horaires d'ouvertures pendant le confinement
--     lon numeric , -- Longitude  
--     lat numeric , -- Latitude 
--     categorie character varying(255) DEFAULT 'Non connu' , -- Catégories en français
--     categorie_regroupee character varying(255) DEFAULT 'Non connu' , -- Catégories en français simplifiée
--     source_nom character varying(255) DEFAULT 'Ça reste ouvert', -- Origine de la donnée
--     source_url text DEFAULT 'https://www.data.gouv.fr/fr/datasets/lieux-ouverts-ou-fermes-pendant-le-confinement-covid-19/', -- URL de la source
--     imageurl text DEFAULT 'https://image.flaticon.com/icons/svg/684/684809.svg', -- Icone de la catégorie
--     geom geometry(Point,4326)-- Géométrie du point en EPSG 4326
--   )
--   ;
--  CREATE INDEX caresteouvert_geom_idx ON sante.caresteouvert USING GIST(geom);


-- -- Schema : sante
-- -- Table : caresteouvert
-- -- Traitement : Intégration csv caresteouvert en base
-- TRUNCATE TABLE sante.caresteouvert;

-- \COPY sante.caresteouvert(name, cat, brand, wikidata, url_hours, infos, status, opening_hours, lon, lat) FROM '/home/mfu/Documents/Projets/coronavirus/jupyter_notebook_coronavirus/data/sources_traitees/caresteouvert.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';


-- --- Schema : sante
-- --- Table : caresteouvert régions
-- --- Traitement : Mise à jour du champ de géométrie
-- UPDATE sante.caresteouvert SET geom = st_setsrid(st_makepoint(lon, lat),4326);

-- --- Schema : sante
-- --- Table : caresteouvert régions
-- --- Traitement : Ne garde que les poi dans l'emprise de Toulouse

-- DELETE FROM sante.caresteouvert
-- WHERE geom NOT IN (SELECT a.geom  FROM sante.caresteouvert a
-- JOIN administratif.dep31 b ON ST_INTERSECTS (a.geom,
-- (st_transform(b.geom, 4326) ) ));

-- --- Schema : sante
-- --- Table : caresteouvert 
-- --- Traitement : Mise à jour du champ categorie

-- UPDATE sante.caresteouvert
-- SET categorie = 
-- CASE 
-- WHEN cat LIKE 'beverages' THEN 'Caviste' 
-- WHEN cat LIKE 'hardware' THEN 'Quincaillerie' 
-- WHEN cat LIKE 'frozen_food' THEN 'Vente de surgelés' 
-- WHEN cat LIKE 'tyres' THEN 'Garage' 
-- WHEN cat LIKE 'laundry' THEN 'Laverie' 
-- WHEN cat LIKE 'hairdresser' THEN 'Coiffeur' 
-- WHEN cat LIKE 'newsagent' THEN 'Papeterie' 
-- WHEN cat LIKE 'supermarket' THEN 'Supermarché' 
-- WHEN cat LIKE 'insurance' THEN 'Assureur' 
-- WHEN cat LIKE 'electronics_repair' THEN 'Magasin de bricolage' 
-- WHEN cat LIKE 'butcher' THEN 'Boucher' 
-- WHEN cat LIKE 'marketplace' THEN 'Marché' 
-- WHEN cat LIKE 'greengrocer' THEN 'Vente de fruits et légumes' 
-- WHEN cat LIKE 'car_repair' THEN 'Garage' 
-- WHEN cat LIKE 'chemist' THEN 'Pharmacies' 
-- WHEN cat LIKE 'kiosk' THEN 'Papeterie' 
-- WHEN cat LIKE 'wine' THEN 'Caviste' 
-- WHEN cat LIKE 'employment_agency' THEN 'Agence de travail temporaire' 
-- WHEN cat LIKE 'pharmacy' THEN 'Pharmacies' 
-- WHEN cat LIKE 'bakery' THEN 'Boulangeries' 
-- WHEN cat LIKE 'stationery' THEN 'Papeterie' 
-- WHEN cat LIKE 'police' THEN 'Commissariat' 
-- WHEN cat LIKE 'tobacco' THEN 'Vente de tabac' 
-- WHEN cat LIKE 'car' THEN 'Garage' 
-- WHEN cat LIKE 'company' THEN 'Société' 
-- WHEN cat LIKE 'fishing' THEN 'Vente de fruits de mer' 
-- WHEN cat LIKE 'car_rental' THEN 'Location de voiture' 
-- WHEN cat LIKE 'electronics' THEN 'Magasin de bricolage' 
-- WHEN cat LIKE 'gas' THEN 'Stations essence' 
-- WHEN cat LIKE 'computer' THEN 'Magasin d''informatique' 
-- WHEN cat LIKE 'fuel' THEN 'Stations essence' 
-- WHEN cat LIKE 'convenience' THEN 'Supérette' 
-- WHEN cat LIKE 'car_parts' THEN 'Magasin de bricolage' 
-- WHEN cat LIKE 'alcohol' THEN 'Caviste' 
-- WHEN cat LIKE 'pet' THEN 'Animalerie' 
-- WHEN cat LIKE 'mobile_phone' THEN 'Magasin de téléphonie' 
-- WHEN cat LIKE 'optician' THEN 'Opticien' 
-- WHEN cat LIKE 'bank' THEN 'Banque' 
-- WHEN cat LIKE 'financial' THEN 'Finance' 
-- WHEN cat LIKE 'funeral_directors' THEN 'Services funéraires' 
-- WHEN cat LIKE 'post_office' THEN 'Bureau de poste' 
-- WHEN cat LIKE 'bicycle' THEN 'Magasin de vente et de réparation de vélos' 
-- WHEN cat LIKE 'variety_store' THEN 'Supérette'
-- WHEN cat LIKE 'convenience;gas' THEN 'Stations essence'
-- WHEN cat LIKE 'bakery;variety_store' THEN 'Boulangeries'
-- END;

-- -- -- --- Schema : sante
-- -- -- --- Table : caresteouvert 
-- -- -- --- Traitement : Mise à jour du champ categorie_regroupee


-- UPDATE sante.caresteouvert
-- SET categorie_regroupee = 
-- CASE 
-- WHEN categorie LIKE 'Laverie' THEN 'Commerces'
-- WHEN categorie LIKE 'Banque' THEN 'Banques et assurances'
-- WHEN categorie LIKE 'Commissariat' THEN 'Commissariat'
-- WHEN categorie LIKE 'Marché' THEN 'Alimentation'
-- WHEN categorie LIKE 'Magasin de bricolage' THEN 'Commerces'
-- WHEN categorie LIKE 'Assureur' THEN 'Banques et assurances'
-- WHEN categorie LIKE 'Finance' THEN 'Banques et assurances'
-- WHEN categorie LIKE 'Magasin de vente et de réparation de vélos' THEN 'Commerces'
-- WHEN categorie LIKE 'Supérette' THEN 'Alimentation'
-- WHEN categorie LIKE 'Pharmacies' THEN 'Pharmacie'
-- WHEN categorie LIKE 'Magasin d''informatique' THEN 'Commerces'
-- WHEN categorie LIKE 'Coiffeur' THEN 'Commerces'
-- WHEN categorie LIKE 'Caviste' THEN 'Alimentation'
-- WHEN categorie LIKE 'Services funéraires' THEN 'Services funéraires'
-- WHEN categorie LIKE 'Supermarché' THEN 'Alimentation'
-- WHEN categorie LIKE 'Stations essence' THEN 'Stations services'
-- WHEN categorie LIKE 'Boucher' THEN 'Alimentation'
-- WHEN categorie LIKE 'Société' THEN 'Commerces'
-- WHEN categorie LIKE 'Vente de surgelés' THEN 'Alimentation'
-- WHEN categorie LIKE 'Papeterie' THEN 'Commerces'
-- WHEN categorie LIKE 'Vente de fruits de mer' THEN 'Alimentation'
-- WHEN categorie LIKE 'Magasin de téléphonie' THEN 'Commerces'
-- WHEN categorie LIKE 'Garage' THEN 'Commerces'
-- WHEN categorie LIKE 'Location de voiture' THEN 'Commerces'
-- WHEN categorie LIKE 'Vente de tabac' THEN 'Commerces'
-- WHEN categorie LIKE 'Opticien' THEN 'Commerces'
-- WHEN categorie LIKE 'Quincaillerie' THEN 'Commerces'
-- WHEN categorie LIKE 'Bureau de poste' THEN 'Bureaux de poste'
-- WHEN categorie LIKE 'Animalerie' THEN 'Commerces'
-- WHEN categorie LIKE 'Vente de fruits et légumes' THEN 'Alimentation'
-- WHEN categorie LIKE 'Boulangeries' THEN 'Boulangeries'
-- WHEN categorie LIKE 'Agence de travail temporaire' THEN 'Commerces'
-- END
-- ;

-- -- --- Schema : sante
-- -- --- Table : caresteouvert 
-- -- --- Traitement : Mise à jour du champ status

-- UPDATE sante.caresteouvert
-- SET status = 
-- CASE 
-- WHEN status LIKE 'ouvert' THEN 'Pas de changement'
-- WHEN status LIKE 'ouvert_adapté' THEN 'Ouvert avec horaires adaptés'
-- WHEN status LIKE 'partiel' THEN 'Certains magasins fermés'
-- WHEN status LIKE 'fermé' THEN 'Tous les magasins fermés'
-- WHEN status IS NULL THEN 'État inconnu'
-- END;

--  -- Schema : sante
--  -- Table : caresteouvert 
--  -- Traitement : Mise à jour du champ imageurl

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2013/240/iconmonstr-credit-card-14.png'
-- where categorie_regroupee = 'Banques et assurances';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2013/240/iconmonstr-shipping-box-3.png'
-- where categorie_regroupee = 'Bureaux de poste';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://image.flaticon.com/icons/svg/1261/1261052.svg'
-- where categorie_regroupee = 'Alimentation';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2013/240/iconmonstr-shop-1.png'
-- where categorie_regroupee = 'Commerces';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://image.flaticon.com/icons/svg/481/481233.svg'
-- where categorie_regroupee = 'Stations services';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2017/240/iconmonstr-medical-13.png'
-- where categorie_regroupee = 'Pharmacies';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-police-1.png'
-- where categorie_regroupee = 'Commissariat';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2017/240/iconmonstr-medical-13.png'
-- where categorie_regroupee = 'Pharmacie';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://image.flaticon.com/icons/svg/2571/2571457.svg'
-- where categorie_regroupee = 'Services funéraires';

-- UPDATE sante.caresteouvert
-- set imageurl = 'https://image.flaticon.com/icons/svg/1888/1888788.svg'
-- where categorie_regroupee = 'Boulangeries';

