# 269527 in NDF-RT
SELECT count(drug_interaction_id) FROM ndf_rt_interaction;
SELECT * FROM ndf_rt_interaction;
SELECT * FROM ndf_rt_interaction WHERE drug_1_rxcui = 3008 AND drug_2_rxcui = 10594;
SELECT * FROM ndf_rt_interaction WHERE drug_1_rxcui = 1005921 AND drug_2_rxcui = 4103;

# 2846 interactions in World Vista
SELECT count(drug_interaction_id) FROM drug_interaction;
SELECT * FROM drug_interaction;
SELECT * FROM drug_interaction WHERE drug_1_rxcui = 3008 AND drug_2_rxcui = 10594;
SELECT * FROM drug_interaction WHERE drug_1_rxcui = 1005921 AND drug_2_rxcui = 4103;
# RxCui's 3008 and 10594 are one example that should overlap

SELECT w.drug_1_rxcui AS world_vista_drug_1,
       w.drug_2_rxcui AS world_vista_drug_2,
       n.drug_1_rxcui AS ndf_rt_drug_1,
       n.drug_2_rxcui AS ndf_rt_drug_2
FROM drug_interaction w
INNER JOIN ndf_rt_interaction n
ON (w.drug_1_rxcui = n.drug_1_rxcui AND w.drug_2_rxcui = n.drug_2_rxcui);
/*WHERE w.drug_1_rxcui = 3008
AND n.drug_1_rxcui = 3008
AND w.drug_2_rxcui = 10594
AND n.drug_2_rxcui = 10594;*/

SELECT w.Drug_1_RxCUI AS world_vista_drug_1,
       w.Drug_2_RxCUI AS world_vista_drug_2,
       n.drug_1_rxcui AS ndf_rt_drug_1,
       n.drug_2_rxcui AS ndf_rt_drug_2
FROM drug_interaction w
INNER JOIN NDF_RT_INTERACTION n
ON (w.Drug_1_RxCUI = n.drug_1_rxcui AND w.dDrug_2_RxCUI = n.drug_2_rxcui);
-- 581 in this overlap (no class overlap)
-- 269527 interactions in NDF-RT
-- 137821 interactions in World Vista when all permutations of class code drugs are accounted for

SELECT g.Drug_Name AS Drug_1_Name,
       g.RxNorm AS Drug_1_RxNorm,
       g.Class_Code AS Class_Code_1,
       h.Drug_Name AS Drug_2_Name,
       h.RxNorm AS Drug_2_RxNorm,
       h.Class_Code AS Class_Code_2,
       i.*
FROM drug_interaction i
LEFT JOIN drug_group g
ON (i.Drug_1_Code = TRIM(TRAILING '\r' FROM g.Class_Code))
LEFT JOIN drug_group h
ON (i.Drug_2_Code = TRIM(TRAILING '\r' FROM h.Class_Code))
ORDER BY i.Drug_Interaction_ID asc;

###############################################################################################################

# 265435 rows cumulative from both data sets (when no blanks, no nulls, duplicates permitted via UNION ALL).
# 261303 rows when no duplicates via UNION
# difference = 5715
# TODO: 1007804, 1111, more have some drug_2_rxcui new line characters
SELECT w.drug_1_rxcui, w.drug_2_rxcui 
FROM drug_interaction w
WHERE w.drug_1_rxcui != '' AND w.drug_2_rxcui != ''
UNION ALL
SELECT n.drug_1_rxcui, n.drug_2_rxcui
FROM ndf_rt_interaction n
WHERE n.drug_1_rxcui is not null AND n.drug_2_rxcui is not null;

# 4577 rows returned for interactions that are in both data sets in any capacity.
SELECT u.drug_1_rxcui, u.drug_2_rxcui, COUNT(*)
FROM(
	SELECT w.drug_1_rxcui, w.drug_2_rxcui 
	FROM drug_interaction w
	WHERE w.drug_1_rxcui != '' AND w.drug_2_rxcui != ''
	UNION ALL
	SELECT n.drug_1_rxcui, n.drug_2_rxcui
	FROM ndf_rt_interaction n
	WHERE n.drug_1_rxcui is not null AND n.drug_2_rxcui is not null) u
GROUP BY u.drug_1_rxcui, u.drug_2_rxcui
HAVING COUNT(*) > 1;

###############################################################################################################

# Original query, but would not fetch

SELECT *
FROM drug_class_interaction w
INNER JOIN NDF_RT_INTERACTION n
ON ((w.Drug_1_RxCUI = n.drug_1_rxcui AND w.Drug_2_RxCUI = n.drug_2_rxcui)
	OR (w.Drug_1_RxNorm = n.drug_1_rxcui AND w.Drug_2_RxCUI = n.drug_2_rxcui)
	OR (w.Drug_1_RxCUI = n.drug_1_rxcui AND w.Drug_2_RxNorm = n.drug_2_rxcui)
    OR (w.Drug_1_RxNorm = n.drug_1_rxcui AND w.Drug_2_RxNorm = n.drug_2_rxcui));
    
###############################################################################################################

# 269527 in NDF-RT
# 137821 Drug Interactions in WorldVista when permutations of drugs in drug classes are accounted for
# 407348 cumulatively with duplicates
# 358210 with no duplicates

SELECT drug_1_rxcui AS rxcui_1, drug_1_rxcui AS rxnorm_1, drug_2_rxcui AS rxcui_2, drug_2_rxcui AS rxnorm_2
	FROM ndf_rt_interaction
	UNION ALL
	SELECT Drug_1_RxCUI, Drug_1_RxNorm, Drug_2_RxCUI, Drug_2_RxNorm
	FROM drug_class_interaction;
