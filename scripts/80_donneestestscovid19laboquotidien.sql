/*
-------------------------------------------------------------------------------------
Auteur : Marine FAUCHER (MAKINA CORPUS)
Date de création : 25/03/2020
Objet : Préparation des données de transferts de patients atteints du covid 19
Modification : Nom : ///// - Date : date_de_modif - Motif/nature : //////

-------------------------------------------------------------------------------------
*/ --- Schema : sante
--- Table : transfertspatientscovid19
--- Traitement : Mise à jour de la géométrie

UPDATE sante.transfertspatientscovid19 a
SET geom_depart = b.geom
FROM
    (SELECT DISTINCT a.region_depart,
                     St_Transform (b.geom,4326) geom
     FROM sante.transfertspatientscovid19 a
     JOIN administratif.chefs_lieux_reg b ON a.region_depart = b.region_nom_reg 
	)b
WHERE a.region_depart = b.region_depart
;

UPDATE sante.transfertspatientscovid19 a
SET geom_arrivee = b.geom
FROM
    (SELECT DISTINCT a.region_arrivee,
                     St_Transform (b.geom,4326) geom
     FROM sante.transfertspatientscovid19 a
     JOIN administratif.chefs_lieux_reg b ON a.region_arrivee = b.region_nom_reg 
	)b
WHERE a.region_arrivee = b.region_arrivee
;