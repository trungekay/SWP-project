IF COL_LENGTH('dbo.Procedure_Order', 'Result_Text') IS NULL
    ALTER TABLE dbo.Procedure_Order ADD Result_Text NVARCHAR(MAX) NULL;

IF COL_LENGTH('dbo.Procedure_Order', 'Result_Conclusion') IS NULL
    ALTER TABLE dbo.Procedure_Order ADD Result_Conclusion NVARCHAR(MAX) NULL;

IF COL_LENGTH('dbo.Procedure_Order', 'Completed_At') IS NULL
    ALTER TABLE dbo.Procedure_Order ADD Completed_At DATETIME2 NULL;

-- Older specialist forms wrote their structured output into the shared clinical record.
-- Keep a copy with the completed order so doctors can see those returned results too.
UPDATE po
SET po.Result_Text = mr.examination_result,
    po.Result_Conclusion = mr.conclusion
FROM dbo.Procedure_Order po
JOIN dbo.Medical_Record mr ON mr.Record_ID = po.Record_ID
WHERE po.Status = 'Completed'
  AND po.Result_Text IS NULL
  AND mr.examination_result LIKE '[[]OD_UCVA:%';
