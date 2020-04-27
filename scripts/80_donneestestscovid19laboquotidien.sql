/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données de transferts de patients atteints du covid 19
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/ 
--- Schema : sante
--- Table : transfertspatientscovid19
--- Traitement : Mise à jour de la géométrie

UPDATE sante.transfertspatientscovid19 a
SET geom_depart = b.geom
FROM
    (SELECT DISTINCT a.region_depart,
                     b.geom
     FROM sante.transfertspatientscovid19 a
     JOIN administratif.chefs_lieux_reg b ON a.region_depart = b.region_nom_reg)b
WHERE a.region_depart = b.region_depart ;


UPDATE sante.transfertspatientscovid19 a
SET geom_arrivee = b.geom
FROM
    (SELECT DISTINCT a.region_arrivee,
                     b.geom
     FROM sante.transfertspatientscovid19 a
     JOIN administratif.chefs_lieux_reg b ON a.region_arrivee = b.region_nom_reg)b
WHERE a.region_arrivee = b.region_arrivee ;

--- Schema : sante
--- Table : transfertspatientscovid19
--- Traitement : Mise à jour des noms de région

UPDATE sante.transfertspatientscovid19
SET region_arrivee = 'Pays de la Loire'
WHERE region_arrivee = 'Pays-de-la-Loire';


UPDATE sante.transfertspatientscovid19
SET region_arrivee = 'Provence-Alpes-Côte d''Azur'
WHERE region_arrivee = 'Provence-Alpes-Côte-d''Azur';

--- Schema : sante
--- Table : transfertspatientscovid19
--- Traitement : Ajout champs coordonnées x/y depart et arrivée

ALTER TABLE sante.transfertspatientscovid19 ADD COLUMN depart_x numeric;
ALTER TABLE sante.transfertspatientscovid19 ADD COLUMN depart_y numeric;
ALTER TABLE sante.transfertspatientscovid19 ADD COLUMN arrivee_x numeric;
ALTER TABLE sante.transfertspatientscovid19 ADD COLUMN arrivee_y numeric;

--- Schema : sante
--- Table : transfertspatientscovid19
--- Traitement : MAJ champs coordonnées x/y depart et arrivée

UPDATE sante.transfertspatientscovid19 a
SET (depart_x,
     depart_y,
     arrivee_x,
     arrivee_y) = (b.depart_x,
                   b.depart_y,
                   b.arrivee_x,
                   b.arrivee_y)
FROM
    (SELECT gid,
            ST_X(geom_depart)depart_x,
            ST_Y(geom_depart)depart_y,
            ST_X(geom_arrivee)arrivee_x,
            ST_Y(geom_arrivee)arrivee_y
     FROM sante.transfertspatientscovid19 )b
WHERE a.gid = b.gid;

