CREATE DATABASE tawos_db;

USE tawos_db;

SELECT * FROM project LIMIT 3;
SELECT * FROM repository LIMIT 3;
SELECT * FROM component LIMIT 3;
SELECT * FROM version LIMIT 3;
SELECT * FROM sprint LIMIT 3;
SELECT * FROM issue_component LIMIT 3;
SELECT * FROM affected_version LIMIT 3;
SELECT * FROM fix_version LIMIT 3;
SELECT * FROM comment LIMIT 3;
SELECT * FROM issue LIMIT 3;

-- Dataset

DROP TABLE IF EXISTS issue_repo_pre_estimation;

CREATE TABLE issue_repo_pre_estimation AS
SELECT
    i.ID AS issue_id,
    i.Jira_ID AS jira_id,
    i.Issue_Key AS issue_key,
    i.URL AS issue_url,

    i.Project_ID AS project_id,
    p.Project_Key AS project_key,
    p.Name AS project_name,
    p.Repository_ID AS repository_id,
    r.Name AS repository_name,
    r.URL AS repository_url,

    i.Sprint_ID AS sprint_id,

    i.Title AS title,
    i.Description_Text AS description_text,
    i.Description_Code AS description_code,

    CONCAT(
        COALESCE(i.Title, ''),
        ' ',
        COALESCE(i.Description_Text, '')
    ) AS input_text,

    i.Type AS issue_type,
    i.Priority AS priority,

    i.Creation_Date AS creation_date,
    i.Estimation_Date AS estimation_date,

    i.Creator_ID AS creator_id,
    i.Reporter_ID AS reporter_id,
    i.Assignee_ID AS assignee_id,

    i.Title_Changed_After_Estimation AS title_changed_after_estimation,
    i.Description_Changed_After_Estimation AS description_changed_after_estimation,
    i.Story_Point_Changed_After_Estimation AS story_point_changed_after_estimation,

    CASE
        WHEN i.Description_Code IS NOT NULL AND LENGTH(TRIM(i.Description_Code)) > 0
        THEN 1 ELSE 0
    END AS has_description_code,

    COALESCE(comp.num_components, 0) AS num_components,
    comp.component_names,

    COALESCE(av.num_affected_versions, 0) AS num_affected_versions,
    av.affected_version_names,

    i.Story_Point AS story_point

FROM issue i

LEFT JOIN project p
    ON i.Project_ID = p.ID

LEFT JOIN repository r
    ON p.Repository_ID = r.ID

LEFT JOIN (
    SELECT
        ic.Issue_ID,
        COUNT(*) AS num_components,
        GROUP_CONCAT(DISTINCT c.Name ORDER BY c.Name SEPARATOR ' | ') AS component_names
    FROM issue_component ic
    LEFT JOIN component c
        ON ic.Component_ID = c.ID
    GROUP BY ic.Issue_ID
) comp
    ON i.ID = comp.Issue_ID

LEFT JOIN (
    SELECT
        av.Issue_ID,
        COUNT(*) AS num_affected_versions,
        GROUP_CONCAT(DISTINCT v.Name ORDER BY v.Name SEPARATOR ' | ') AS affected_version_names
    FROM affected_version av
    LEFT JOIN version v
        ON av.Affected_Version_ID = v.ID
    GROUP BY av.Issue_ID
) av
    ON i.ID = av.Issue_ID

WHERE i.Story_Point IS NOT NULL
  AND i.Story_Point BETWEEN 1 AND 100
  AND i.Story_Point_Changed_After_Estimation = 0
  AND i.Title IS NOT NULL
  AND i.Description_Text IS NOT NULL;
  
SELECT COUNT(*) FROM issue_repo_pre_estimation;

describe issue_repo_pre_estimation;

SELECT
    issue_id,
    issue_key,
    project_key,
    repository_name,
    issue_type,
    priority,
    num_components,
    component_names,
    num_affected_versions,
    story_point
FROM issue_repo_pre_estimation
LIMIT 10;
  

