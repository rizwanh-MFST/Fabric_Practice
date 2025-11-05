-- =========================================================================
-- Microsoft Fabric - Army Readiness Analytics
-- SQL Scripts for Semantic Model Development
-- =========================================================================
-- Purpose: Query and validate Silver/Gold tables for Power BI semantic model
-- Author: Microsoft Fabric Lab
-- Classification: UNCLASSIFIED // FOR TRAINING USE ONLY
-- =========================================================================

-- =========================================================================
-- SECTION 1: DATA VALIDATION & EXPLORATION
-- =========================================================================

-- 1.1 List all available tables
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 1.2 Get row counts for all data layers
SELECT 'bronze_personnel_readiness' AS TableName, COUNT(*) AS RowCount FROM bronze_personnel_readiness
UNION ALL
SELECT 'bronze_equipment_inventory', COUNT(*) FROM bronze_equipment_inventory
UNION ALL
SELECT 'bronze_training_metrics', COUNT(*) FROM bronze_training_metrics
UNION ALL
SELECT 'silver_personnel_readiness', COUNT(*) FROM silver_personnel_readiness
UNION ALL
SELECT 'silver_equipment_inventory', COUNT(*) FROM silver_equipment_inventory
UNION ALL
SELECT 'silver_training_metrics', COUNT(*) FROM silver_training_metrics
UNION ALL
SELECT 'gold_unit_readiness_summary', COUNT(*) FROM gold_unit_readiness_summary
UNION ALL
SELECT 'gold_equipment_by_unit', COUNT(*) FROM gold_equipment_by_unit
ORDER BY TableName;


-- =========================================================================
-- SECTION 2: PERSONNEL READINESS QUERIES
-- =========================================================================

-- 2.1 Current Unit Readiness Status (Latest Report Date)
SELECT 
    Division,
    Brigade,
    UnitName,
    UnitID,
    ReportDate,
    ReadinessStatus,
    ReadinessScore,
    PersonnelAssigned,
    PersonnelPresent,
    PersonnelPresentPct,
    ReadinessCategory
FROM silver_personnel_readiness
WHERE ReportDate = (SELECT MAX(ReportDate) FROM silver_personnel_readiness)
ORDER BY ReadinessScore DESC;

-- 2.2 Readiness Trend by Unit (Time Series)
SELECT 
    UnitName,
    Brigade,
    Division,
    ReportDate,
    ReadinessScore,
    PersonnelPresentPct,
    ReadinessStatus
FROM silver_personnel_readiness
ORDER BY UnitName, ReportDate;

-- 2.3 Division-Level Readiness Summary
SELECT 
    Division,
    COUNT(DISTINCT UnitID) AS TotalUnits,
    ROUND(AVG(ReadinessScore), 2) AS AvgReadinessScore,
    ROUND(AVG(PersonnelPresentPct), 2) AS AvgPersonnelPresent,
    SUM(PersonnelAssigned) AS TotalPersonnelAssigned,
    SUM(PersonnelPresent) AS TotalPersonnelPresent,
    SUM(PersonnelAbsent) AS TotalPersonnelAbsent
FROM silver_personnel_readiness
WHERE ReportDate = (SELECT MAX(ReportDate) FROM silver_personnel_readiness)
GROUP BY Division
ORDER BY AvgReadinessScore DESC;

-- 2.4 Units Below Readiness Threshold
SELECT 
    UnitName,
    Brigade,
    Division,
    ReadinessScore,
    ReadinessStatus,
    PersonnelPresentPct,
    PersonnelAbsent,
    ReportDate
FROM silver_personnel_readiness
WHERE ReadinessScore < 90
    AND ReportDate = (SELECT MAX(ReportDate) FROM silver_personnel_readiness)
ORDER BY ReadinessScore ASC;

-- 2.5 Readiness Category Distribution
SELECT 
    ReadinessCategory,
    COUNT(*) AS UnitCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM silver_personnel_readiness
WHERE ReportDate = (SELECT MAX(ReportDate) FROM silver_personnel_readiness)
GROUP BY ReadinessCategory
ORDER BY 
    CASE ReadinessCategory
        WHEN 'Excellent' THEN 1
        WHEN 'Good' THEN 2
        WHEN 'Satisfactory' THEN 3
        WHEN 'Needs Improvement' THEN 4
    END;


-- =========================================================================
-- SECTION 3: EQUIPMENT INVENTORY QUERIES
-- =========================================================================

-- 3.1 Equipment Operational Status Summary
SELECT 
    EquipmentType,
    COUNT(DISTINCT EquipmentID) AS TotalItems,
    SUM(Quantity) AS TotalQuantity,
    SUM(OperationalQty) AS TotalOperational,
    SUM(MaintenanceQty) AS TotalMaintenance,
    SUM(NonOperationalQty) AS TotalNonOperational,
    ROUND(AVG(OperationalPct), 2) AS AvgOperationalPct
FROM silver_equipment_inventory
GROUP BY EquipmentType
ORDER BY AvgOperationalPct DESC;

-- 3.2 Equipment Needing Attention (Low Operational %)
SELECT 
    EquipmentID,
    EquipmentType,
    EquipmentName,
    UnitID,
    Quantity,
    OperationalQty,
    OperationalPct,
    ConditionStatus,
    InspectionStatus,
    DaysUntilInspection
FROM silver_equipment_inventory
WHERE OperationalPct < 80 OR ConditionStatus = 'NEEDS_ATTENTION'
ORDER BY OperationalPct ASC;

-- 3.3 Inspection Due/Overdue Equipment
SELECT 
    InspectionStatus,
    EquipmentType,
    COUNT(*) AS ItemCount,
    SUM(Quantity) AS TotalEquipment
FROM silver_equipment_inventory
GROUP BY InspectionStatus, EquipmentType
ORDER BY 
    CASE InspectionStatus
        WHEN 'Overdue' THEN 1
        WHEN 'Due Soon' THEN 2
        WHEN 'Current' THEN 3
    END,
    EquipmentType;

-- 3.4 Equipment Condition by Unit
SELECT 
    ei.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    ei.ConditionStatus,
    COUNT(*) AS ItemCount,
    SUM(ei.Quantity) AS TotalEquipment
FROM silver_equipment_inventory ei
LEFT JOIN (
    SELECT DISTINCT UnitID, UnitName, Brigade, Division 
    FROM silver_personnel_readiness
) pr ON ei.UnitID = pr.UnitID
GROUP BY ei.UnitID, pr.UnitName, pr.Brigade, pr.Division, ei.ConditionStatus
ORDER BY pr.Division, pr.Brigade, ei.UnitID, ei.ConditionStatus;

-- 3.5 Critical Equipment (Vehicles & Weapons) Readiness
SELECT 
    EquipmentType,
    EquipmentName,
    SUM(Quantity) AS Total,
    SUM(OperationalQty) AS Operational,
    SUM(NonOperationalQty) AS NonOperational,
    ROUND((SUM(OperationalQty) * 100.0 / SUM(Quantity)), 2) AS OperationalPct
FROM silver_equipment_inventory
WHERE EquipmentType IN ('Vehicle', 'Weapon')
GROUP BY EquipmentType, EquipmentName
ORDER BY OperationalPct ASC;


-- =========================================================================
-- SECTION 4: TRAINING METRICS QUERIES
-- =========================================================================

-- 4.1 Training Completion Summary by Type
SELECT 
    TrainingType,
    COUNT(*) AS TotalEvents,
    SUM(ParticipantsScheduled) AS TotalScheduled,
    SUM(ParticipantsCompleted) AS TotalCompleted,
    ROUND(AVG(CompletionRate), 2) AS AvgCompletionRate,
    ROUND(AVG(PassRate), 2) AS AvgPassRate,
    ROUND(AVG(AverageScore), 2) AS AvgScore
FROM silver_training_metrics
WHERE TrainingStatus = 'COMPLETED'
GROUP BY TrainingType
ORDER BY AvgPassRate DESC;

-- 4.2 Training Effectiveness Distribution
SELECT 
    TrainingEffectiveness,
    COUNT(*) AS EventCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM silver_training_metrics
WHERE TrainingStatus = 'COMPLETED'
GROUP BY TrainingEffectiveness
ORDER BY 
    CASE TrainingEffectiveness
        WHEN 'Highly Effective' THEN 1
        WHEN 'Effective' THEN 2
        WHEN 'Satisfactory' THEN 3
        WHEN 'Needs Improvement' THEN 4
    END;

-- 4.3 Unit Training Performance
SELECT 
    tm.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    COUNT(*) AS TrainingEvents,
    ROUND(AVG(tm.CompletionRate), 2) AS AvgCompletionRate,
    ROUND(AVG(tm.PassRate), 2) AS AvgPassRate,
    SUM(tm.ParticipantsCompleted) AS TotalParticipants
FROM silver_training_metrics tm
LEFT JOIN (
    SELECT DISTINCT UnitID, UnitName, Brigade, Division 
    FROM silver_personnel_readiness
) pr ON tm.UnitID = pr.UnitID
WHERE tm.TrainingStatus = 'COMPLETED'
GROUP BY tm.UnitID, pr.UnitName, pr.Brigade, pr.Division
ORDER BY AvgPassRate DESC;

-- 4.4 Recent Training Activity (Last 30 Days)
SELECT 
    tm.UnitID,
    pr.UnitName,
    tm.TrainingType,
    tm.TrainingName,
    tm.CompletedDate,
    tm.ParticipantsCompleted,
    tm.PassRate,
    tm.TrainingEffectiveness
FROM silver_training_metrics tm
LEFT JOIN (
    SELECT DISTINCT UnitID, UnitName, Brigade, Division 
    FROM silver_personnel_readiness
) pr ON tm.UnitID = pr.UnitID
WHERE tm.CompletedDate >= DATEADD(day, -30, GETDATE())
    AND tm.TrainingStatus = 'COMPLETED'
ORDER BY tm.CompletedDate DESC;

-- 4.5 Training Types Needing Improvement
SELECT 
    TrainingType,
    TrainingName,
    COUNT(*) AS Events,
    ROUND(AVG(PassRate), 2) AS AvgPassRate,
    ROUND(AVG(CompletionRate), 2) AS AvgCompletionRate
FROM silver_training_metrics
WHERE TrainingEffectiveness IN ('Needs Improvement', 'Satisfactory')
    AND TrainingStatus = 'COMPLETED'
GROUP BY TrainingType, TrainingName
HAVING COUNT(*) >= 2
ORDER BY AvgPassRate ASC;


-- =========================================================================
-- SECTION 5: GOLD LAYER ANALYTICS (Executive Reporting)
-- =========================================================================

-- 5.1 Overall Unit Readiness Summary
SELECT 
    OverallReadiness,
    COUNT(*) AS UnitCount,
    ROUND(AVG(AvgReadinessScore), 2) AS AvgScore,
    ROUND(AVG(AvgPersonnelPresent), 2) AS AvgPersonnelPresent
FROM gold_unit_readiness_summary
GROUP BY OverallReadiness
ORDER BY 
    CASE OverallReadiness
        WHEN 'GREEN' THEN 1
        WHEN 'AMBER' THEN 2
        WHEN 'RED' THEN 3
    END;

-- 5.2 Division Readiness Dashboard
SELECT 
    Division,
    COUNT(*) AS TotalUnits,
    SUM(CASE WHEN OverallReadiness = 'GREEN' THEN 1 ELSE 0 END) AS GreenUnits,
    SUM(CASE WHEN OverallReadiness = 'AMBER' THEN 1 ELSE 0 END) AS AmberUnits,
    SUM(CASE WHEN OverallReadiness = 'RED' THEN 1 ELSE 0 END) AS RedUnits,
    ROUND(AVG(AvgReadinessScore), 2) AS AvgReadinessScore,
    ROUND(AVG(AvgPersonnelPresent), 2) AS AvgPersonnelPresent,
    SUM(AvgPersonnelAssigned) AS TotalPersonnel
FROM gold_unit_readiness_summary
GROUP BY Division
ORDER BY AvgReadinessScore DESC;

-- 5.3 Brigade Readiness Comparison
SELECT 
    Division,
    Brigade,
    COUNT(*) AS TotalUnits,
    ROUND(AVG(AvgReadinessScore), 2) AS AvgReadinessScore,
    ROUND(AVG(AvgPersonnelPresent), 2) AS AvgPersonnelPresent,
    MAX(LatestReportDate) AS LastReportDate
FROM gold_unit_readiness_summary
GROUP BY Division, Brigade
ORDER BY Division, AvgReadinessScore DESC;

-- 5.4 Top and Bottom Performing Units
-- Top 10 Units
SELECT TOP 10
    UnitName,
    Brigade,
    Division,
    AvgReadinessScore,
    OverallReadiness,
    AvgPersonnelPresent
FROM gold_unit_readiness_summary
ORDER BY AvgReadinessScore DESC;

-- Bottom 10 Units
SELECT TOP 10
    UnitName,
    Brigade,
    Division,
    AvgReadinessScore,
    OverallReadiness,
    AvgPersonnelPresent
FROM gold_unit_readiness_summary
ORDER BY AvgReadinessScore ASC;

-- 5.5 Equipment Readiness by Unit (Gold)
SELECT 
    Division,
    Brigade,
    UnitName,
    EquipmentType,
    TotalEquipment,
    TotalOperational,
    TotalMaintenance,
    TotalNonOperational,
    AvgOperationalPct
FROM gold_equipment_by_unit
ORDER BY Division, Brigade, UnitName, EquipmentType;

-- 5.6 Division Equipment Summary
SELECT 
    Division,
    EquipmentType,
    SUM(TotalEquipment) AS TotalEquipment,
    SUM(TotalOperational) AS TotalOperational,
    SUM(TotalMaintenance) AS TotalMaintenance,
    SUM(TotalNonOperational) AS TotalNonOperational,
    ROUND(AVG(AvgOperationalPct), 2) AS AvgOperationalPct
FROM gold_equipment_by_unit
GROUP BY Division, EquipmentType
ORDER BY Division, AvgOperationalPct DESC;


-- =========================================================================
-- SECTION 6: INTEGRATED ANALYTICS (Cross-Domain Insights)
-- =========================================================================

-- 6.1 Comprehensive Unit Dashboard (Personnel + Equipment + Training)
SELECT 
    pr.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    pr.AvgReadinessScore AS PersonnelReadiness,
    pr.OverallReadiness AS PersonnelStatus,
    ROUND(AVG(eq.AvgOperationalPct), 2) AS EquipmentReadiness,
    COUNT(DISTINCT tm.TrainingID) AS TrainingEventsCompleted,
    ROUND(AVG(tm.PassRate), 2) AS AvgTrainingPassRate
FROM gold_unit_readiness_summary pr
LEFT JOIN gold_equipment_by_unit eq ON pr.UnitID = eq.UnitID
LEFT JOIN silver_training_metrics tm ON pr.UnitID = tm.UnitID 
    AND tm.TrainingStatus = 'COMPLETED'
GROUP BY 
    pr.UnitID, pr.UnitName, pr.Brigade, pr.Division, 
    pr.AvgReadinessScore, pr.OverallReadiness
ORDER BY pr.Division, pr.Brigade, pr.UnitName;

-- 6.2 Readiness Correlation: Personnel vs Equipment
SELECT 
    pr.Division,
    pr.Brigade,
    pr.UnitName,
    pr.AvgReadinessScore AS PersonnelScore,
    ROUND(AVG(eq.AvgOperationalPct), 2) AS EquipmentScore,
    ROUND(ABS(pr.AvgReadinessScore - AVG(eq.AvgOperationalPct)), 2) AS ScoreDelta,
    CASE 
        WHEN pr.AvgReadinessScore >= 90 AND AVG(eq.AvgOperationalPct) >= 90 THEN 'Both Ready'
        WHEN pr.AvgReadinessScore >= 90 AND AVG(eq.AvgOperationalPct) < 90 THEN 'Personnel Ready, Equipment Limited'
        WHEN pr.AvgReadinessScore < 90 AND AVG(eq.AvgOperationalPct) >= 90 THEN 'Equipment Ready, Personnel Limited'
        ELSE 'Both Need Attention'
    END AS ReadinessAssessment
FROM gold_unit_readiness_summary pr
LEFT JOIN gold_equipment_by_unit eq ON pr.UnitID = eq.UnitID
GROUP BY pr.Division, pr.Brigade, pr.UnitName, pr.AvgReadinessScore
ORDER BY ScoreDelta DESC;

-- 6.3 Training Impact on Readiness
SELECT 
    pr.Division,
    COUNT(DISTINCT pr.UnitID) AS TotalUnits,
    ROUND(AVG(pr.AvgReadinessScore), 2) AS AvgReadinessScore,
    COUNT(DISTINCT tm.TrainingID) AS TotalTrainingEvents,
    ROUND(AVG(tm.PassRate), 2) AS AvgTrainingPassRate,
    ROUND(AVG(tm.CompletionRate), 2) AS AvgCompletionRate
FROM gold_unit_readiness_summary pr
LEFT JOIN silver_training_metrics tm ON pr.UnitID = tm.UnitID 
    AND tm.TrainingStatus = 'COMPLETED'
GROUP BY pr.Division
ORDER BY AvgReadinessScore DESC;

-- 6.4 Risk Assessment: Units with Multiple Challenges
SELECT 
    pr.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    pr.AvgReadinessScore,
    pr.OverallReadiness,
    ROUND(AVG(eq.AvgOperationalPct), 2) AS EquipmentReadiness,
    ROUND(AVG(tm.PassRate), 2) AS TrainingPassRate,
    CASE 
        WHEN pr.AvgReadinessScore < 85 THEN 1 ELSE 0 
    END +
    CASE 
        WHEN AVG(eq.AvgOperationalPct) < 80 THEN 1 ELSE 0 
    END +
    CASE 
        WHEN AVG(tm.PassRate) < 85 THEN 1 ELSE 0 
    END AS RiskFactors
FROM gold_unit_readiness_summary pr
LEFT JOIN gold_equipment_by_unit eq ON pr.UnitID = eq.UnitID
LEFT JOIN silver_training_metrics tm ON pr.UnitID = tm.UnitID 
    AND tm.TrainingStatus = 'COMPLETED'
GROUP BY 
    pr.UnitID, pr.UnitName, pr.Brigade, pr.Division, 
    pr.AvgReadinessScore, pr.OverallReadiness
HAVING 
    CASE WHEN pr.AvgReadinessScore < 85 THEN 1 ELSE 0 END +
    CASE WHEN AVG(eq.AvgOperationalPct) < 80 THEN 1 ELSE 0 END +
    CASE WHEN AVG(tm.PassRate) < 85 THEN 1 ELSE 0 END >= 2
ORDER BY RiskFactors DESC, pr.AvgReadinessScore ASC;


-- =========================================================================
-- SECTION 7: TIME-BASED ANALYTICS
-- =========================================================================

-- 7.1 Readiness Trend Over Time (Monthly)
SELECT 
    DATEPART(YEAR, ReportDate) AS Year,
    DATEPART(MONTH, ReportDate) AS Month,
    Division,
    COUNT(DISTINCT UnitID) AS Units,
    ROUND(AVG(ReadinessScore), 2) AS AvgReadinessScore,
    ROUND(AVG(PersonnelPresentPct), 2) AS AvgPersonnelPresent
FROM silver_personnel_readiness
GROUP BY DATEPART(YEAR, ReportDate), DATEPART(MONTH, ReportDate), Division
ORDER BY Year, Month, Division;

-- 7.2 Month-over-Month Readiness Change
WITH MonthlyReadiness AS (
    SELECT 
        UnitID,
        UnitName,
        Division,
        DATEPART(YEAR, ReportDate) AS Year,
        DATEPART(MONTH, ReportDate) AS Month,
        AVG(ReadinessScore) AS AvgScore
    FROM silver_personnel_readiness
    GROUP BY UnitID, UnitName, Division, DATEPART(YEAR, ReportDate), DATEPART(MONTH, ReportDate)
)
SELECT 
    curr.UnitName,
    curr.Division,
    curr.Year,
    curr.Month,
    curr.AvgScore AS CurrentScore,
    prev.AvgScore AS PreviousScore,
    ROUND(curr.AvgScore - prev.AvgScore, 2) AS ScoreChange,
    CASE 
        WHEN curr.AvgScore > prev.AvgScore THEN 'Improved'
        WHEN curr.AvgScore < prev.AvgScore THEN 'Declined'
        ELSE 'Stable'
    END AS Trend
FROM MonthlyReadiness curr
LEFT JOIN MonthlyReadiness prev 
    ON curr.UnitID = prev.UnitID 
    AND curr.Year = prev.Year 
    AND curr.Month = prev.Month + 1
WHERE prev.AvgScore IS NOT NULL
ORDER BY ScoreChange ASC;


-- =========================================================================
-- SECTION 8: DATA QUALITY & VALIDATION
-- =========================================================================

-- 8.1 Check for NULL values in critical fields
SELECT 
    'Personnel' AS DataSource,
    SUM(CASE WHEN UnitID IS NULL THEN 1 ELSE 0 END) AS NullUnitID,
    SUM(CASE WHEN ReadinessScore IS NULL THEN 1 ELSE 0 END) AS NullReadinessScore,
    SUM(CASE WHEN ReportDate IS NULL THEN 1 ELSE 0 END) AS NullReportDate
FROM silver_personnel_readiness
UNION ALL
SELECT 
    'Equipment',
    SUM(CASE WHEN UnitID IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN OperationalPct IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN LastInspectionDate IS NULL THEN 1 ELSE 0 END)
FROM silver_equipment_inventory
UNION ALL
SELECT 
    'Training',
    SUM(CASE WHEN UnitID IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN PassRate IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN CompletedDate IS NULL THEN 1 ELSE 0 END)
FROM silver_training_metrics;

-- 8.2 Data freshness check
SELECT 
    'Personnel' AS DataSource,
    MAX(ReportDate) AS LatestDate,
    DATEDIFF(day, MAX(ReportDate), GETDATE()) AS DaysOld
FROM silver_personnel_readiness
UNION ALL
SELECT 
    'Equipment',
    MAX(LastInspectionDate),
    DATEDIFF(day, MAX(LastInspectionDate), GETDATE())
FROM silver_equipment_inventory
UNION ALL
SELECT 
    'Training',
    MAX(CompletedDate),
    DATEDIFF(day, MAX(CompletedDate), GETDATE())
FROM silver_training_metrics;

-- 8.3 Referential integrity check (UnitIDs exist across tables)
SELECT DISTINCT 
    pr.UnitID,
    pr.UnitName,
    CASE WHEN eq.UnitID IS NOT NULL THEN 'Yes' ELSE 'No' END AS HasEquipmentData,
    CASE WHEN tm.UnitID IS NOT NULL THEN 'Yes' ELSE 'No' END AS HasTrainingData
FROM silver_personnel_readiness pr
LEFT JOIN (SELECT DISTINCT UnitID FROM silver_equipment_inventory) eq ON pr.UnitID = eq.UnitID
LEFT JOIN (SELECT DISTINCT UnitID FROM silver_training_metrics) tm ON pr.UnitID = tm.UnitID
ORDER BY pr.UnitID;


-- =========================================================================
-- SECTION 9: VIEWS FOR SEMANTIC MODEL (Optional)
-- =========================================================================

-- 9.1 Create view for current readiness status
CREATE OR ALTER VIEW vw_Current_Unit_Readiness AS
SELECT 
    pr.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    pr.ReadinessScore,
    pr.ReadinessStatus,
    pr.PersonnelAssigned,
    pr.PersonnelPresent,
    pr.PersonnelPresentPct,
    pr.ReadinessCategory,
    pr.ReportDate
FROM silver_personnel_readiness pr
WHERE pr.ReportDate = (SELECT MAX(ReportDate) FROM silver_personnel_readiness);

-- 9.2 Create view for equipment summary
CREATE OR ALTER VIEW vw_Equipment_Summary AS
SELECT 
    eq.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    eq.EquipmentType,
    eq.EquipmentName,
    eq.Quantity,
    eq.OperationalQty,
    eq.OperationalPct,
    eq.ConditionStatus,
    eq.InspectionStatus
FROM silver_equipment_inventory eq
LEFT JOIN (
    SELECT DISTINCT UnitID, UnitName, Brigade, Division 
    FROM silver_personnel_readiness
) pr ON eq.UnitID = pr.UnitID;

-- 9.3 Create view for training performance
CREATE OR ALTER VIEW vw_Training_Performance AS
SELECT 
    tm.UnitID,
    pr.UnitName,
    pr.Brigade,
    pr.Division,
    tm.TrainingType,
    tm.TrainingName,
    tm.CompletedDate,
    tm.CompletionRate,
    tm.PassRate,
    tm.TrainingEffectiveness
FROM silver_training_metrics tm
LEFT JOIN (
    SELECT DISTINCT UnitID, UnitName, Brigade, Division 
    FROM silver_personnel_readiness
) pr ON tm.UnitID = pr.UnitID
WHERE tm.TrainingStatus = 'COMPLETED';


-- =========================================================================
-- END OF SQL SCRIPTS
-- =========================================================================
-- Next Steps:
-- 1. Run validation queries to ensure data quality
-- 2. Use Gold layer tables for semantic model creation
-- 3. Create relationships in Power BI based on UnitID
-- 4. Build DAX measures for KPIs and metrics
-- =========================================================================
