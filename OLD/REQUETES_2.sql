-- 1. Nombre total d’appartements vendus au 1er semestre 2020
SELECT COUNT(*) AS Total_Appartements_S1
FROM Bien
WHERE Type_Local LIKE 'Appartement%' 
AND Date_Mutation BETWEEN '2020-01-01' AND '2020-06-30'


-- 2. Le nombre de ventes d’appartement par région pour le 1er semestre 2020
SELECT r.Nom_Region, COUNT(b.ID_Bien) AS Nombre_Ventes
FROM Bien b
JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
JOIN DEPARTEMENT d ON c.Code_Departement = d.Code_Departement
JOIN REGION r ON d.Code_Region = r.Code_Region
WHERE b.Type_Local LIKE 'Appartement%' 
AND b.Date_Mutation BETWEEN '2020-01-01' AND '2020-06-30'
GROUP BY r.Nom_Region



-- 3. Proportion des ventes d’appartements par le nombre de pièces
SELECT Nombre_pieces_principales, 
       COUNT(*) AS Nb_Ventes,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Bien WHERE Type_Local LIKE 'Appartement%'), 2) || '%' AS Proportion
FROM Bien
WHERE Type_Local LIKE 'Appartement%'
GROUP BY Nombre_pieces_principales



-- 4. Liste des 10 départements où le prix du mètre carré est le plus élevé
SELECT d.Code_Departement, d.Nom_Departement, 
       ROUND(AVG(b.Valeur_Fonciere / b.Surface_reelle_bati), 2) AS Prix_m2_Moyen
FROM Bien b
JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
JOIN DEPARTEMENT d ON c.Code_Departement = d.Code_Departement
WHERE b.Surface_reelle_bati > 0
GROUP BY d.Code_Departement, d.Nom_Departement
ORDER BY Prix_m2_Moyen DESC
LIMIT 10



-- 5. Prix moyen du mètre carré d’une maison en Île-de-France
SELECT ROUND(AVG(b.Valeur_Fonciere / b.Surface_reelle_bati), 2) AS Prix_m2_Moyen_IDF
FROM Bien b
JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
JOIN DEPARTEMENT d ON c.Code_Departement = d.Code_Departement
JOIN REGION r ON d.Code_Region = r.Code_Region
WHERE b.Type_Local LIKE 'Maison%' 
AND r.Nom_Region = 'Ile-de-France'
AND b.Surface_reelle_bati > 0



-- 6. Liste des 10 appartements les plus chers avec la région et le nombre de m2
SELECT r.Nom_Region, b.Surface_reelle_bati, b.Valeur_Fonciere
FROM Bien b
JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
JOIN DEPARTEMENT d ON c.Code_Departement = d.Code_Departement
JOIN REGION r ON d.Code_Region = r.Code_Region
WHERE b.Type_Local LIKE 'Appartement%'
ORDER BY b.Valeur_Fonciere DESC
LIMIT 10



-- 7. Taux d’évolution du nombre de ventes entre le T1 et le T2 2020
WITH Ventes_T1 AS (SELECT COUNT(*) AS Nb_T1 FROM Bien WHERE Date_Mutation BETWEEN '2020-01-01' AND '2020-03-31'),
     Ventes_T2 AS (SELECT COUNT(*) AS Nb_T2 FROM Bien WHERE Date_Mutation BETWEEN '2020-04-01' AND '2020-06-30')
SELECT Nb_T1, Nb_T2,
       ROUND(((CAST(Nb_T2 AS FLOAT) - Nb_T1) / Nb_T1) * 100, 2) || '%' AS Taux_Evolution
FROM Ventes_T1, Ventes_T2



-- 8. Classement des régions par prix au m2 (Appartements > 4 pièces)
SELECT r.Nom_Region, ROUND(AVG(b.Valeur_Fonciere / b.Surface_reelle_bati), 2) AS Prix_m2_Moyen
FROM Bien b
JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
JOIN DEPARTEMENT d ON c.Code_Departement = d.Code_Departement
JOIN REGION r ON d.Code_Region = r.Code_Region
WHERE b.Type_Local LIKE 'Appartement%' 
AND b.Nombre_pieces_principales > 4 AND b.Surface_reelle_bati > 0
GROUP BY r.Nom_Region ORDER BY Prix_m2_Moyen DESC




-- 9. Communes ayant eu au moins 50 ventes au 1er trimestre 2020
SELECT c.Nom_Commune, COUNT(b.ID_Bien) AS Nb_Ventes
FROM Bien b
JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
WHERE b.Date_Mutation BETWEEN '2020-01-01' AND '2020-03-31'
GROUP BY c.Code_Commune, c.Nom_Commune
HAVING Nb_Ventes >= 40 ORDER BY Nb_Ventes DESC



-- 10. Différence (%) de prix au m2 entre Appartement T2 et T3
WITH Prix_T2 AS (SELECT AVG(Valeur_Fonciere / Surface_reelle_bati) AS Moyenne_T2 FROM Bien WHERE Nombre_pieces_principales = 2 AND Type_Local LIKE 'Appartement%' AND Surface_reelle_bati > 0),
     Prix_T3 AS (SELECT AVG(Valeur_Fonciere / Surface_reelle_bati) AS Moyenne_T3 FROM Bien WHERE Nombre_pieces_principales = 3 AND Type_Local LIKE 'Appartement%' AND Surface_reelle_bati > 0)
SELECT ROUND(((Moyenne_T3 - Moyenne_T2) / Moyenne_T2) * 100, 2) || '%' AS Diff_Pourcentage FROM Prix_T2, Prix_T3



-- 11. Moyennes de valeurs foncières pour le top 3 des communes (Dept 6, 13, 33, 59, 69)
WITH Moyennes AS (
    SELECT d.Code_Departement, c.Nom_Commune, AVG(b.Valeur_Fonciere) AS Moyenne_Commune,
           RANK() OVER (PARTITION BY d.Code_Departement ORDER BY AVG(b.Valeur_Fonciere) DESC) AS Rang
    FROM Bien b
    JOIN COMMUNE c ON b.Code_Commune = c.Code_Commune
    JOIN DEPARTEMENT d ON c.Code_Departement = d.Code_Departement
    WHERE d.Code_Departement IN ('06', '13', '33', '59', '69')
    GROUP BY d.Code_Departement, c.Nom_Commune)
SELECT Code_Departement, Nom_Commune, ROUND(Moyenne_Commune, 2) AS Moyenne_Valeur FROM Moyennes WHERE Rang <= 3



-- 12. Les 20 communes avec le plus de transactions pour 1000 habitants pour les communes qui dépassent les 10 000 habitants
SELECT 
    C.Nom_Commune, 
    C.Population_Totale,
    COUNT(B.ID_Bien) AS Nb_Transactions,
    ROUND((COUNT(B.ID_Bien) * 1000.0) / C.Population_Totale, 2) AS Ratio
FROM COMMUNE C
JOIN BIEN B ON C.Code_Commune = B.Code_Commune
WHERE C.Population_Totale > 10000
GROUP BY C.Code_Commune -- On groupe par Code pour éviter les homonymes
ORDER BY Ratio DESC
LIMIT 20;