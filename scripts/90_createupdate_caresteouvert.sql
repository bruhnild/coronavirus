
-- -------------------------------------------------------------------------------------
-- -- Auteur : Marine FAUCHER (MAKINA CORPUS)
-- -- Date de création : 25/03/2020
-- -- Objet : Préparation des données ça reste ouvert
-- -- Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////
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
--     enseigne boolean , -- Enseigne oui ou non
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

-- \COPY sante.caresteouvert(name, cat, brand, wikidata, url_hours, infos, status, opening_hours, lon, lat) FROM '/home/mfu/Documents/Projets/coronavirus/data/sources_traitees/caresteouvert.csv'DELIMITER ',' CSV HEADER ENCODING 'utf8' NULL '';


-- --- Schema : sante
-- --- Table : caresteouvert
-- --- Traitement : Mise à jour du champ de géométrie
-- UPDATE sante.caresteouvert SET geom = st_setsrid(st_makepoint(lon, lat),4326);

-- --- Schema : sante
-- --- Table : caresteouvert
-- --- Traitement : Mise à jour des champ enseigne et source_url
-- UPDATE sante.caresteouvert a
-- SET (enseigne, source_url) = (b.enseigne, b.source_url)
-- FROM 
-- (SELECT DISTINCT a.gid, true as enseigne, b.source_url
-- FROM sante.caresteouvert a
-- JOIN sante.caresteouvert_rules b ON a.cat = b.category AND a.brand = b.brand_name)b
-- WHERE a.gid = b.gid;

-- --- Schema : sante
-- --- Table : caresteouvert 
-- --- Traitement : Mise à jour du champ categorie

-- UPDATE sante.caresteouvert
-- SET categorie = 
-- CASE 
-- WHEN cat LIKE 'beverages' THEN 'Vente d''alcool' 
-- WHEN cat LIKE 'hardware' THEN 'Droguerie' 
-- WHEN cat LIKE 'frozen_food' THEN 'Vente de surgelés' 
-- WHEN cat LIKE 'tyres' THEN 'Bricolage' 
-- WHEN cat LIKE 'laundry' THEN 'Laverie' 
-- WHEN cat LIKE 'hairdresser' THEN 'Coiffeur' 
-- WHEN cat LIKE 'newsagent' THEN 'Journeaux' 
-- WHEN cat LIKE 'supermarket' THEN 'Supermarché' 
-- WHEN cat LIKE 'insurance' THEN 'Assurance' 
-- WHEN cat LIKE 'electronics_repair' THEN 'Bricolage' 
-- WHEN cat LIKE 'butcher' THEN 'Boucherie' 
-- WHEN cat LIKE 'marketplace' THEN 'Marché' 
-- WHEN cat LIKE 'greengrocer' THEN 'Primeur' 
-- WHEN cat LIKE 'car_repair' THEN 'Garage' 
-- WHEN cat LIKE 'chemist' THEN 'Pharmacie' 
-- WHEN cat LIKE 'kiosk' THEN 'Journeaux' 
-- WHEN cat LIKE 'wine' THEN 'Vente d''alcool' 
-- WHEN cat LIKE 'employment_agency' THEN 'Agence pour l''emploi' 
-- WHEN cat LIKE 'pharmacy' THEN 'Pharmacie' 
-- WHEN cat LIKE 'bakery' THEN 'Boulangerie' 
-- WHEN cat LIKE 'stationery' THEN 'Journeaux' 
-- WHEN cat LIKE 'police' THEN 'Commissariat' 
-- WHEN cat LIKE 'tobacco' THEN 'Tabac' 
-- WHEN cat LIKE 'car' THEN 'Garage' 
-- WHEN cat LIKE 'company' THEN 'Société' 
-- WHEN cat LIKE 'fishing' THEN 'Vente de fruits de mer' 
-- WHEN cat LIKE 'car_rental' THEN 'Location de voiture' 
-- WHEN cat LIKE 'electronics' THEN 'Matériel électronique' 
-- WHEN cat LIKE 'gas' THEN 'Station-service' 
-- WHEN cat LIKE 'computer' THEN 'Informatique' 
-- WHEN cat LIKE 'fuel' THEN 'Station-service' 
-- WHEN cat LIKE 'convenience' THEN 'Supérette' 
-- WHEN cat LIKE 'car_parts' THEN 'Bricolage' 
-- WHEN cat LIKE 'alcohol' THEN 'Vente d''alcool' 
-- WHEN cat LIKE 'pet' THEN 'Animalerie' 
-- WHEN cat LIKE 'mobile_phone' THEN 'Téléphonie mobile' 
-- WHEN cat LIKE 'optician' THEN 'Opticien' 
-- WHEN cat LIKE 'bank' THEN 'Banque' 
-- WHEN cat LIKE 'financial' THEN 'Finance' 
-- WHEN cat LIKE 'funeral_directors' THEN 'Pompes funèbres' 
-- WHEN cat LIKE 'post_office' THEN 'Services postaux' 
-- WHEN cat LIKE 'bicycle' THEN 'Magasin de vélos' 
-- WHEN cat LIKE 'variety_store' THEN 'Supérette'
-- WHEN cat LIKE 'convenience;gas' THEN 'Stations essence'
-- WHEN cat LIKE 'bakery;variety_store' THEN 'Boulangerie'
-- WHEN cat LIKE 'condoms' THEN 'Distributeur de préservatifs'
-- WHEN cat LIKE 'e_cigarette' THEN 'E-cigarette'
-- WHEN cat LIKE 'restaurant' THEN 'Restaurant'
-- WHEN cat LIKE 'bar' THEN 'Bar'
-- WHEN cat LIKE 'coffee' THEN 'Café'
-- WHEN cat LIKE 'public_transport_tickets' THEN 'Distributeur de titres de transport'
-- WHEN cat LIKE 'hotel' THEN 'Hôtel'
-- WHEN cat LIKE 'health_center' THEN 'Centre médical'
-- WHEN cat LIKE 'cafe' THEN 'Café'
-- WHEN cat LIKE 'cheese' THEN 'Fromagerie'
-- WHEN cat LIKE 'childcare' THEN 'Garde d''enfants'
-- WHEN cat LIKE 'farm' THEN 'Magasin à la ferme'
-- WHEN cat LIKE 'agrarian' THEN 'Magasin à la ferme'
-- WHEN cat LIKE 'seafood' THEN 'Poisonnier'
-- WHEN cat LIKE 'dairy' THEN 'Crémier'
-- WHEN cat LIKE 'grocery' THEN 'Épicerie'
-- WHEN cat LIKE 'fast_food' THEN 'Restauration rapide'
-- WHEN cat LIKE 'townhall' THEN 'Mairie'
-- WHEN cat LIKE 'covid19_centre' THEN 'Centre de consultation Covid-19'
-- WHEN cat LIKE 'tea' THEN 'Thé'
-- WHEN cat LIKE 'medical_supply' THEN 'Matériel médical'
-- WHEN cat LIKE 'confectionery' THEN 'Confiserie'
-- WHEN cat LIKE 'chocolate' THEN 'Chocolaterie'
-- WHEN cat LIKE 'hearing_aids' THEN 'Appareils auditifs'
-- WHEN cat LIKE 'flower' THEN 'Fleuriste'
-- WHEN cat LIKE 'vending_machine' THEN 'Distributeur automatique'
-- END;

-- -- -- --- Schema : sante
-- -- -- --- Table : caresteouvert 
-- -- -- --- Traitement : Mise à jour du champ categorie_regroupee


-- UPDATE sante.caresteouvert
-- SET categorie_regroupee = null;
-- UPDATE sante.caresteouvert
-- SET categorie_regroupee = 
-- CASE 
-- WHEN categorie LIKE 'Distributeur de titres de transport' THEN 'Mobilité'
-- WHEN categorie LIKE 'Magasin de vélos' THEN 'Mobilité'
-- WHEN categorie LIKE 'Station-service' THEN 'Mobilité'
-- WHEN categorie LIKE 'Garage' THEN 'Mobilité' 
-- WHEN categorie LIKE 'Location de voiture' THEN 'Mobilité' 

-- WHEN categorie LIKE 'Bar' THEN 'Restauration'
-- WHEN categorie LIKE 'Restaurant' THEN 'Restauration'
-- WHEN cat LIKE 'cafe' AND categorie LIKE 'Café' THEN 'Restauration'
-- WHEN categorie LIKE 'Restauration rapide' THEN 'Restauration'
-- WHEN categorie LIKE 'Distributeur automatique' THEN 'Restauration'

-- WHEN categorie LIKE 'Cigarette électronique' THEN 'Tabac et alcool'
-- WHEN categorie LIKE 'Caviste' THEN 'Tabac et alcool'
-- WHEN categorie LIKE 'Vente de tabac' THEN 'Tabac et alcool'
-- WHEN categorie LIKE 'E-cigarette' THEN 'Tabac et alcool'
-- WHEN categorie LIKE 'Tabac' THEN 'Tabac et alcool'
-- WHEN categorie LIKE 'Vente d''alcool' THEN 'Tabac et alcool'

-- WHEN categorie LIKE 'Distributeur de préservatifs' THEN 'Santé'
-- WHEN categorie LIKE 'Pharmacie' THEN 'Santé'
-- WHEN categorie LIKE 'Opticien' THEN 'Santé'
-- WHEN categorie LIKE 'Centre médical' THEN 'Santé'
-- WHEN categorie LIKE 'Centre de consultation Covid-19' THEN 'Santé'
-- WHEN categorie LIKE 'Matériel médical' THEN 'Santé'
-- WHEN categorie LIKE 'Appareils auditifs' THEN 'Santé'


-- WHEN categorie LIKE 'Laverie' THEN 'Boutiques'
-- WHEN categorie LIKE 'Coiffeur' THEN 'Boutiques'
-- WHEN categorie LIKE 'Bricolage' THEN 'Boutiques'
-- WHEN categorie LIKE 'Société' THEN 'Boutiques'
-- WHEN categorie LIKE 'Journeaux' THEN 'Boutiques'
-- WHEN categorie LIKE 'Garage' THEN 'Boutiques'
-- WHEN categorie LIKE 'Fleuriste' THEN 'Boutiques'
-- WHEN categorie LIKE 'Droguerie' THEN 'Boutiques'
-- WHEN categorie LIKE 'Matériel électronique' THEN 'Boutiques'
-- WHEN categorie LIKE 'Animalerie' THEN 'Boutiques'
-- WHEN categorie LIKE 'Informatique' THEN 'Boutiques'
-- WHEN categorie LIKE 'Téléphonie mobile' THEN 'Boutiques'

-- WHEN categorie LIKE 'Banque' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Commissariat' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Assurance' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Finance' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Pompes funèbres' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Agence pour l''emploi' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Garde d''enfants' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Services postaux' THEN 'Services pratiques'
-- WHEN categorie LIKE 'Mairie' THEN 'Services pratiques'

-- WHEN categorie LIKE 'Marché' THEN 'Alimentation'
-- WHEN categorie LIKE 'Thé' THEN 'Alimentation'
-- WHEN categorie LIKE 'Poisonnier' THEN 'Alimentation'
-- WHEN categorie LIKE 'Crémier' THEN 'Alimentation'
-- WHEN categorie LIKE 'Boulangerie' THEN 'Alimentation'
-- WHEN categorie LIKE 'Épicerie' THEN 'Alimentation'
-- WHEN categorie LIKE 'Magasin à la ferme' THEN 'Alimentation'
-- WHEN categorie LIKE 'Supérette' THEN 'Alimentation'
-- WHEN categorie LIKE 'Vente de surgelés' THEN 'Alimentation'
-- WHEN categorie LIKE 'Vente de fruits de mer' THEN 'Alimentation'
-- WHEN categorie LIKE 'Supermarché' THEN 'Alimentation'
-- WHEN categorie LIKE 'Boucherie' THEN 'Alimentation'
-- WHEN categorie LIKE 'Primeur' THEN 'Alimentation'
-- WHEN categorie LIKE 'Fromagerie' THEN 'Alimentation'
-- WHEN categorie LIKE 'Confiserie' THEN 'Alimentation'
-- WHEN categorie LIKE 'Chocolaterie' THEN 'Alimentation'
-- WHEN cat LIKE 'coffee' AND categorie LIKE 'Café' THEN 'Alimentation'

-- WHEN categorie LIKE 'Hôtel' THEN 'Autres établissements'

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
-- SET imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-email-2.png'
-- WHERE categorie_regroupee = 'Services pratiques';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://image.flaticon.com/icons/svg/1942/1942319.svg'
-- WHERE categorie_regroupee = 'Tabac et alcool';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://image.flaticon.com/icons/svg/1261/1261052.svg'
-- WHERE categorie_regroupee = 'Alimentation';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://image.flaticon.com/icons/svg/1374/1374128.svg'
-- WHERE categorie_regroupee = 'Boutiques';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://image.flaticon.com/icons/svg/2164/2164589.svg'
-- WHERE categorie_regroupee = 'Mobilité';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://cdns.iconmonstr.com/wp-content/assets/preview/2017/240/iconmonstr-medical-13.png'
-- WHERE categorie_regroupee = 'Santé';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://image.flaticon.com/icons/svg/1046/1046857.svg'
-- WHERE categorie_regroupee = 'Restauration';

-- UPDATE sante.caresteouvert
-- SET imageurl = 'https://image.flaticon.com/icons/svg/684/684809.svg'
-- WHERE categorie_regroupee = 'Autres établissements';

