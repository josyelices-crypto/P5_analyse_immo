

-- INDEX

CREATE INDEX IF NOT EXISTS idx_commune_brut_nom ON commune_brut(COM, CODDEP);
CREATE INDEX IF NOT EXISTS idx_ref_nom ON referentiel_brut(com_nom, dep_code);


-- ESSAI / NETTOYAGE 

DROP TABLE IF EXISTS POPULATION_DEP;
CREATE TABLE POPULATION_COM (
    Code_Commune VARCHAR(5) NOT NULL PRIMARY KEY,
    Population_Totale INTEGER,
    FOREIGN KEY (Code_Commune) REFERENCES COMMUNE(Code_Commune));

UPDATE COMMUNE SET Population_Totale = 0;

UPDATE COMMUNE
SET Population_Totale = CB.PTOT
FROM commune_brut CB
WHERE COMMUNE.Nom_Commune = CB.COM 
  AND COMMUNE.Code_Departement = CB.CODDEP;

UPDATE COMMUNE
SET Population_Totale = 0
WHERE Population_Totale IS NULL;

SELECT Code_Commune, Nom_Commune 
FROM COMMUNE 
WHERE Population_Totale = 0;




-- UNIFORMISATION EN MAJUSCULE ET SANS ACCENT

UPDATE COMMUNE 
SET Nom_Commune = UPPER(REPLACE(REPLACE(Nom_Commune, '-', ' '), '''', ' '));UPDATE COMMUNE 

UPDATE commune_brut 
SET COM = UPPER(REPLACE(REPLACE(COM, '-', ' '), '''', ' '));

UPDATE COMMUNE 
SET Nom_Commune = UPPER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        Nom_Commune, 
        'é', 'e'), 'è', 'e'), 'ê', 'e'), 'ë', 'e'), 
        'ç', 'c'), 'à', 'a'), 'î', 'i'));

UPDATE commune_brut 
SET COM = UPPER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        COM, 
        'é', 'e'), 'è', 'e'), 'ê', 'e'), 'ë', 'e'), 
        'ç', 'c'), 'à', 'a'), 'î', 'i'));

UPDATE COMMUNE 
SET Nom_Commune = REPLACE(REPLACE(Nom_Commune, 'â', 'A'), 'Ã', 'I');
UPDATE commune_brut
SET COM = REPLACE(REPLACE(COM, 'â', 'A'), 'Ã', 'I');

UPDATE COMMUNE 
SET Nom_Commune = TRIM(REPLACE(Nom_Commune, '  ', ' '));
UPDATE commune_brut
SET COM = TRIM(REPLACE(COM, '  ', ' '));











-- SUPP DEPARTEMENTS HORS FRANCE/DOM-TOM 

DELETE FROM COMMUNE 
WHERE Code_Departement LIKE '98%';

DELETE FROM COMMUNE 
WHERE Code_Commune LIKE '985%' 
   OR Code_Commune LIKE '975%' 
   OR Code_Commune LIKE '977%' 
   OR Code_Commune LIKE '978%';

INSERT INTO DEPARTEMENT (Code_Departement, Nom_Departement, Code_Region)
VALUES ('976', 'Mayotte', '6');
UPDATE REGION SET Code_Region = TRIM(Code_Region);
UPDATE DEPARTEMENT SET Code_Region = TRIM(Code_Region);


-- RESET LIGNE MAYOTTE
DELETE FROM REGION WHERE Code_Region = '6' OR Code_Region = '06' OR Nom_Region = 'Mayotte';
INSERT INTO REGION (Code_Region, Nom_Region) VALUES ('6', 'Mayotte');
UPDATE DEPARTEMENT SET Code_Region = '6' WHERE Code_Departement = '976';

SELECT 
    TRIM(Code_Commune) AS Code, 
    Nom_Commune AS Ville, 
    'Mayotte' AS Departement
FROM COMMUNE
WHERE TRIM(Code_Departement) = '976' 
   OR CAST(Code_Departement AS UNSIGNED) = 976;


-- TEST VISIBILITE MAYOTTE 
SELECT 
    d.Code_Departement AS Code_Dep,
    d.Nom_Departement AS Departement,
    COUNT(b.Id_Bien) AS Nb_Ventes,
    IFNULL(ROUND(AVG(b.Valeur_Fonciere), 2), 0) AS Prix_Moyen
FROM DEPARTEMENT AS d
LEFT JOIN COMMUNE AS c ON d.Code_Departement = c.Code_Departement
LEFT JOIN BIEN AS b ON c.Code_Commune = b.Code_Commune
GROUP BY d.Code_Departement, d.Nom_Departement
ORDER BY Nb_Ventes DESC;


-- RENAME 



-- MODIF. TABLE DEPARTEMENT 
INSERT INTO DEPARTEMENT (Code_Departement, Nom_Departement, Code_Region)
VALUES 
('2A', 'Corse-du-Sud', '94'),
('2B', 'Haute-Corse', '94');

SELECT * FROM DEPARTEMENT 
WHERE Code_Departement IN ('2A', '2B') 
OR Code_Region = '94';




-- REQUETE 12

SELECT Code_Commune, Population_Totale 
FROM POPULATION 
WHERE Identifiant_Commune IN ('75056', '13055', '69123', 'MARSEILLE', 'LYON', 'PARIS');