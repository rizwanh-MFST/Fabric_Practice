# Microsoft Fabric Lab: Army Unit Readiness Analytics
## Lab Guide for US Army Operations

---

## **Lab Overview**

**Objective**: Build an end-to-end analytics solution in Microsoft Fabric to track and analyze Army unit readiness metrics.

**Duration**: Approximately 3-4 hours

**Scenario**: You are a data analyst supporting Army operations. Your mission is to integrate personnel readiness, equipment inventory, and training metrics data to provide commanders with actionable insights on unit readiness status.

**What You'll Learn**:
- Ingest data into a Fabric Lakehouse using Data Pipelines
- Transform data using Notebooks (PySpark) and Dataflows
- Create a semantic model for reporting
- Build Power BI reports for operational dashboards

**Prerequisites**:
- Access to Microsoft Fabric workspace with F32 capacity
- Basic understanding of SQL and data concepts
- Familiarity with Power BI

---

## **Lab Architecture**

```
CSV Data Sources
    ↓
Data Pipeline (Ingestion)
    ↓
Lakehouse (Bronze Layer - Raw Data)
    ↓
Notebook/Dataflow (ETL Transformations)
    ↓
Lakehouse (Silver/Gold Layer - Curated Data)
    ↓
Semantic Model
    ↓
Power BI Report
```

---

## **Part 1: Environment Setup (15 minutes)**

### **Exercise 1.1: Create a Fabric Workspace**

1. Navigate to [Microsoft Fabric](https://app.fabric.microsoft.com)
2. Click on **Workspaces** in the left navigation pane
3. Click **+ New workspace**
4. Configure the workspace:
   - **Name**: `Army_Readiness_Analytics`
   - **Description**: `Workspace for Army unit readiness reporting and analytics`
   - **Advanced** → **License mode**: Select your F32 capacity
5. Click **Apply**

### **Exercise 1.2: Create a Lakehouse**

1. In your workspace, click **+ New** → **Lakehouse**
2. Name it: `ArmyReadinessLakehouse`
3. Click **Create**
4. You should see three folders:
   - **Files**: For unstructured data
   - **Tables**: For Delta tables
   - **Schemas**: For organizing tables

> **Note**: The Lakehouse is built on Delta Lake and provides ACID transactions, scalability, and unified batch/streaming processing.

---

## **Part 2: Data Ingestion with Data Pipeline (30 minutes)**

### **Exercise 2.1: Upload Sample Data Files**

For this lab, we'll use three CSV files representing Army operational data:

1. **personnel_readiness.csv** - Unit personnel status and readiness scores
2. **equipment_inventory.csv** - Equipment condition and maintenance status  
3. **training_metrics.csv** - Training completion and performance data

**Upload the files to Lakehouse Files folder:**

1. In your Lakehouse, click on the **Files** folder
2. Click **Upload** → **Upload files**
3. Upload all three CSV files from the `sample-data` folder:
   - `personnel_readiness.csv`
   - `equipment_inventory.csv`
   - `training_metrics.csv`
4. Verify files appear in the **Files** folder

> **💡 Tip**: In a production environment, you might pull data from SQL databases, REST APIs, or file shares. Pipelines support 100+ data connectors.

### **Exercise 2.2: Create a Data Pipeline**

Now we'll create a pipeline to copy the CSV data into Delta tables.

1. Navigate to your workspace: `Army_Readiness_Analytics`
2. Click **+ New** → **Data Pipeline**
3. Name it: `Pipeline_Ingest_Readiness_Data`
4. Click **Create**

### **Exercise 2.3: Add Copy Data Activity (Personnel Readiness)**

1. In the Pipeline canvas, click **Copy data** activity from the toolbar
2. Rename the activity to: `Copy_Personnel_Readiness`

**Configure Source:**
1. Click on the activity → **Source** tab
2. Click **+ New** next to Connection
3. Select **Workspace**
4. Navigate to: **ArmyReadinessLakehouse** → **Files** → `personnel_readiness.csv`
5. Click **Create**
6. **File format**: Select **DelimitedText**
7. Check **First row as header**

**Configure Destination:**
1. Click on the activity → **Destination** tab
2. Click **+ New** next to Connection
3. Select **Workspace** → **ArmyReadinessLakehouse** → **Tables**
4. Table name: `bronze_personnel_readiness`
5. Click **Create**
6. **Table action**: Select **Overwrite**

### **Exercise 2.4: Add Activities for Equipment and Training Data**

Repeat Exercise 2.3 for the other two datasets:

**Copy Activity 2: Equipment Inventory**
- Activity name: `Copy_Equipment_Inventory`
- Source: `equipment_inventory.csv`
- Destination table: `bronze_equipment_inventory`

**Copy Activity 3: Training Metrics**
- Activity name: `Copy_Training_Metrics`
- Source: `training_metrics.csv`
- Destination table: `bronze_training_metrics`

**Connect Activities in Sequence:**
1. Drag the green success arrow from `Copy_Personnel_Readiness` to `Copy_Equipment_Inventory`
2. Drag the green success arrow from `Copy_Equipment_Inventory` to `Copy_Training_Metrics`

### **Exercise 2.5: Run the Pipeline**

1. Click **Run** at the top of the pipeline canvas
2. Click **Save and run**
3. Monitor the pipeline execution in the **Output** pane at the bottom
4. All three activities should complete successfully (green checkmarks)

**Verify Data Ingestion:**
1. Navigate back to **ArmyReadinessLakehouse**
2. Click on **Tables** folder
3. You should see three new tables:
   - `bronze_personnel_readiness`
   - `bronze_equipment_inventory`
   - `bronze_training_metrics`
4. Click on each table to preview the data

> **✅ Checkpoint**: You now have raw data loaded into Bronze layer tables!

---

## **Part 3: Data Transformation with Notebooks (45 minutes)**

### **Exercise 3.1: Create a Notebook**

1. Navigate to your workspace: `Army_Readiness_Analytics`
2. Click **+ New** → **Notebook**
3. Name it: `Transform_Readiness_Data`
4. In the **Lakehouse** pane on the left, click **Add** → **Existing Lakehouse**
5. Select `ArmyReadinessLakehouse` → Click **Add**

### **Exercise 3.2: Transform Personnel Readiness Data**

Add the following code cells to your notebook:

**Cell 1: Load and Explore Bronze Data**
```python
# Load bronze personnel readiness data
df_personnel = spark.table("bronze_personnel_readiness")

# Display schema and sample data
print("Schema:")
df_personnel.printSchema()

print("\nRow count:", df_personnel.count())
print("\nSample data:")
display(df_personnel.limit(10))
```

**Run the cell** to verify data loaded correctly.

**Cell 2: Add Calculated Columns**
```python
from pyspark.sql.functions import col, round, when, current_timestamp

# Create silver layer with calculated metrics
df_personnel_silver = df_personnel \
    .withColumn("PersonnelPresentPct", 
                round((col("PersonnelPresent") / col("PersonnelAssigned")) * 100, 2)) \
    .withColumn("PersonnelAbsent", 
                col("PersonnelAssigned") - col("PersonnelPresent")) \
    .withColumn("ReadinessCategory", 
                when(col("ReadinessScore") >= 95, "Excellent")
                .when(col("ReadinessScore") >= 90, "Good")
                .when(col("ReadinessScore") >= 85, "Satisfactory")
                .otherwise("Needs Improvement")) \
    .withColumn("ETL_LoadDate", current_timestamp())

# Display transformed data
print("Transformed data with calculated columns:")
display(df_personnel_silver.limit(10))
```

**Cell 3: Write to Silver Layer**
```python
# Write to silver layer table
df_personnel_silver.write.mode("overwrite").saveAsTable("silver_personnel_readiness")

print("✅ Silver personnel readiness table created successfully!")
```

### **Exercise 3.3: Transform Equipment Inventory Data**

**Cell 4: Transform Equipment Data**
```python
from pyspark.sql.functions import col, round, when, current_timestamp, datediff, to_date

# Load bronze equipment data
df_equipment = spark.table("bronze_equipment_inventory")

# Create silver layer with equipment metrics
df_equipment_silver = df_equipment \
    .withColumn("OperationalPct", 
                round((col("OperationalQty") / col("Quantity")) * 100, 2)) \
    .withColumn("MaintenancePct", 
                round((col("MaintenanceQty") / col("Quantity")) * 100, 2)) \
    .withColumn("NonOperationalPct", 
                round((col("NonOperationalQty") / col("Quantity")) * 100, 2)) \
    .withColumn("DaysUntilInspection", 
                datediff(to_date(col("NextInspectionDate")), current_timestamp())) \
    .withColumn("InspectionStatus", 
                when(col("DaysUntilInspection") < 0, "Overdue")
                .when(col("DaysUntilInspection") <= 7, "Due Soon")
                .otherwise("Current")) \
    .withColumn("ETL_LoadDate", current_timestamp())

# Write to silver layer
df_equipment_silver.write.mode("overwrite").saveAsTable("silver_equipment_inventory")

print("✅ Silver equipment inventory table created successfully!")
display(df_equipment_silver.limit(10))
```

### **Exercise 3.4: Transform Training Metrics Data**

**Cell 5: Transform Training Data**
```python
from pyspark.sql.functions import col, round, when, current_timestamp

# Load bronze training data
df_training = spark.table("bronze_training_metrics")

# Create silver layer with training metrics
df_training_silver = df_training \
    .withColumn("CompletionRate", 
                round((col("ParticipantsCompleted") / col("ParticipantsScheduled")) * 100, 2)) \
    .withColumn("TrainingEffectiveness", 
                when((col("PassRate") >= 95) & (col("CompletionRate") >= 95), "Highly Effective")
                .when((col("PassRate") >= 90) & (col("CompletionRate") >= 90), "Effective")
                .when((col("PassRate") >= 85) & (col("CompletionRate") >= 85), "Satisfactory")
                .otherwise("Needs Improvement")) \
    .withColumn("ETL_LoadDate", current_timestamp())

# Write to silver layer
df_training_silver.write.mode("overwrite").saveAsTable("silver_training_metrics")

print("✅ Silver training metrics table created successfully!")
display(df_training_silver.limit(10))
```

### **Exercise 3.5: Create Gold Layer - Unified Readiness View**

**Cell 6: Create Aggregated Gold Table**
```python
from pyspark.sql.functions import col, avg, sum, count, max as spark_max

# Create gold layer - Unit readiness summary
df_unit_summary = df_personnel_silver \
    .groupBy("UnitID", "UnitName", "Brigade", "Division") \
    .agg(
        avg("ReadinessScore").alias("AvgReadinessScore"),
        avg("PersonnelPresentPct").alias("AvgPersonnelPresent"),
        count("*").alias("ReportCount"),
        spark_max("ReportDate").alias("LatestReportDate")
    ) \
    .withColumn("OverallReadiness",
                when(col("AvgReadinessScore") >= 95, "GREEN")
                .when(col("AvgReadinessScore") >= 90, "AMBER")
                .otherwise("RED"))

# Write to gold layer
df_unit_summary.write.mode("overwrite").saveAsTable("gold_unit_readiness_summary")

print("✅ Gold unit readiness summary table created successfully!")
display(df_unit_summary.orderBy(col("AvgReadinessScore").desc()))
```

**Cell 7: Create Equipment Readiness by Unit**
```python
# Join equipment with personnel to get unit details
df_equipment_by_unit = df_equipment_silver.alias("eq") \
    .join(
        df_personnel_silver.select("UnitID", "UnitName", "Brigade", "Division").distinct().alias("pr"),
        col("eq.UnitID") == col("pr.UnitID"),
        "left"
    ) \
    .groupBy(
        col("pr.UnitID"),
        col("pr.UnitName"),
        col("pr.Brigade"),
        col("pr.Division"),
        col("eq.EquipmentType")
    ) \
    .agg(
        sum("eq.Quantity").alias("TotalEquipment"),
        sum("eq.OperationalQty").alias("TotalOperational"),
        sum("eq.MaintenanceQty").alias("TotalMaintenance"),
        sum("eq.NonOperationalQty").alias("TotalNonOperational"),
        avg("eq.OperationalPct").alias("AvgOperationalPct")
    )

# Write to gold layer
df_equipment_by_unit.write.mode("overwrite").saveAsTable("gold_equipment_by_unit")

print("✅ Gold equipment by unit table created successfully!")
display(df_equipment_by_unit.limit(10))
```

**Run all cells** to complete the transformations.

> **✅ Checkpoint**: You now have transformed data in Silver and Gold layers ready for reporting!

---

## **Part 4: Alternative - Data Transformation with Dataflow Gen2 (Optional)**

If you prefer a low-code approach, you can use Dataflow Gen2 instead of notebooks:

### **Exercise 4.1: Create a Dataflow Gen2**

1. Navigate to your workspace: `Army_Readiness_Analytics`
2. Click **+ New** → **Dataflow Gen2**
3. Name it: `Dataflow_Transform_Personnel`

### **Exercise 4.2: Add Data Source**

1. Click **Get data** → **More...**
2. Search for and select **Lakehouse**
3. Connect to `ArmyReadinessLakehouse`
4. Select table: `bronze_personnel_readiness`
5. Click **Create**

### **Exercise 4.3: Add Transformations**

1. In Power Query Editor, add a custom column:
   - Click **Add column** → **Custom column**
   - Name: `PersonnelPresentPct`
   - Formula: `([PersonnelPresent] / [PersonnelAssigned]) * 100`
   
2. Add another custom column:
   - Name: `ReadinessCategory`
   - Formula: 
     ```
     if [ReadinessScore] >= 95 then "Excellent"
     else if [ReadinessScore] >= 90 then "Good"
     else if [ReadinessScore] >= 85 then "Satisfactory"
     else "Needs Improvement"
     ```

### **Exercise 4.4: Set Data Destination**

1. Click **Add data destination** → **Lakehouse**
2. Select `ArmyReadinessLakehouse`
3. Table name: `silver_personnel_readiness_df`
4. Update method: **Replace**

5. Click **Publish**

6. The dataflow will run and create your silver table

> **💡 Tip**: Dataflows are great for business users familiar with Power Query. Notebooks offer more flexibility for complex transformations.

---

## **Part 5: Create Semantic Model (30 minutes)**

### **Exercise 5.1: Create a New Semantic Model**

1. Navigate to `ArmyReadinessLakehouse`
2. Click **SQL analytics endpoint** (at the top of the lakehouse)
3. This opens the SQL view where you can query tables using T-SQL

**Verify Tables:**
```sql
-- List all tables
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

4. Click **New semantic model** button at the top
5. Name it: `ArmyReadinessSemanticModel`
6. Select the following tables:
   - ✅ `silver_personnel_readiness`
   - ✅ `silver_equipment_inventory`
   - ✅ `silver_training_metrics`
   - ✅ `gold_unit_readiness_summary`
   - ✅ `gold_equipment_by_unit`
7. Click **Confirm**

### **Exercise 5.2: Define Relationships**

1. The semantic model will open in model view
2. Create relationships by dragging fields between tables:

**Relationship 1: Personnel → Training**
- From: `silver_personnel_readiness[UnitID]`
- To: `silver_training_metrics[UnitID]`
- Cardinality: Many-to-Many
- Cross filter direction: Both

**Relationship 2: Personnel → Equipment**
- From: `silver_personnel_readiness[UnitID]`
- To: `silver_equipment_inventory[UnitID]`
- Cardinality: Many-to-Many
- Cross filter direction: Both

**Relationship 3: Gold Summary → Personnel**
- From: `gold_unit_readiness_summary[UnitID]`
- To: `silver_personnel_readiness[UnitID]`
- Cardinality: One-to-Many
- Cross filter direction: Both

### **Exercise 5.3: Create Measures**

1. Click on `gold_unit_readiness_summary` table
2. Click **New measure** in the ribbon
3. Add the following DAX measures:

**Measure 1: Total Units**
```dax
Total Units = DISTINCTCOUNT(gold_unit_readiness_summary[UnitID])
```

**Measure 2: Units GREEN Status**
```dax
Units GREEN = 
CALCULATE(
    [Total Units],
    gold_unit_readiness_summary[OverallReadiness] = "GREEN"
)
```

**Measure 3: Units AMBER Status**
```dax
Units AMBER = 
CALCULATE(
    [Total Units],
    gold_unit_readiness_summary[OverallReadiness] = "AMBER"
)
```

**Measure 4: Units RED Status**
```dax
Units RED = 
CALCULATE(
    [Total Units],
    gold_unit_readiness_summary[OverallReadiness] = "RED"
)
```

**Measure 5: Readiness Percentage**
```dax
Readiness % = 
DIVIDE(
    [Units GREEN],
    [Total Units],
    0
) * 100
```

4. Click on `silver_equipment_inventory` table and add:

**Measure 6: Total Equipment Items**
```dax
Total Equipment = SUM(silver_equipment_inventory[Quantity])
```

**Measure 7: Operational Equipment**
```dax
Operational Equipment = SUM(silver_equipment_inventory[OperationalQty])
```

**Measure 8: Equipment Readiness %**
```dax
Equipment Readiness % = 
DIVIDE(
    [Operational Equipment],
    [Total Equipment],
    0
) * 100
```

5. Click on `silver_training_metrics` table and add:

**Measure 9: Average Training Pass Rate**
```dax
Avg Training Pass Rate = AVERAGE(silver_training_metrics[PassRate])
```

**Measure 10: Total Training Events**
```dax
Total Training Events = COUNTROWS(silver_training_metrics)
```

6. Click **Save** to save the semantic model

---

## **Part 6: Build Power BI Report (45 minutes)**

### **Exercise 6.1: Create a New Report**

1. From the semantic model page, click **Create report** button
2. This opens Power BI in edit mode with your semantic model connected

### **Exercise 6.2: Create Report Page 1 - Executive Dashboard**

**Add Report Title:**
1. Insert → Text box
2. Type: "ARMY UNIT READINESS DASHBOARD"
3. Format: Font size 24, Bold, Center aligned
4. Background color: Dark blue (#003366)
5. Font color: White

**Visual 1: Key Metrics Cards**
1. Insert → **Card** visual (repeat 4 times for 4 cards)
2. Arrange horizontally across the top

**Card 1 - Total Units:**
- Field: `[Total Units]`
- Format: Callout value size 48pt

**Card 2 - Readiness %:**
- Field: `[Readiness %]`
- Format: Display units → None, Decimal places → 1
- Conditional formatting: Green if > 90

**Card 3 - Equipment Readiness %:**
- Field: `[Equipment Readiness %]`
- Format: Display units → None, Decimal places → 1

**Card 4 - Avg Training Pass Rate:**
- Field: `[Avg Training Pass Rate]`
- Format: Display units → None, Decimal places → 1

**Visual 2: Readiness Status by Division (Stacked Bar Chart)**
1. Insert → **Stacked bar chart**
2. Y-axis: `gold_unit_readiness_summary[Division]`
3. X-axis: `[Total Units]`
4. Legend: `gold_unit_readiness_summary[OverallReadiness]`
5. Format → Data colors:
   - GREEN → Green (#00FF00)
   - AMBER → Yellow (#FFD700)
   - RED → Red (#FF0000)
6. Title: "Unit Readiness Status by Division"

**Visual 3: Readiness Score Trend (Line Chart)**
1. Insert → **Line chart**
2. X-axis: `silver_personnel_readiness[ReportDate]`
3. Y-axis: `silver_personnel_readiness[ReadinessScore]` (Average)
4. Legend: `silver_personnel_readiness[Brigade]`
5. Title: "Readiness Score Trend by Brigade"

**Visual 4: Equipment Operational Status (Donut Chart)**
1. Insert → **Donut chart**
2. Legend: `silver_equipment_inventory[ConditionStatus]`
3. Values: `[Total Equipment]`
4. Title: "Equipment Condition Status"

**Visual 5: Training Effectiveness (Clustered Column Chart)**
1. Insert → **Clustered column chart**
2. X-axis: `silver_training_metrics[TrainingType]`
3. Y-axis: `[Avg Training Pass Rate]`
4. Title: "Training Pass Rates by Type"

### **Exercise 6.3: Create Report Page 2 - Personnel Readiness Detail**

1. Click **+ New page** at the bottom
2. Add page title: "PERSONNEL READINESS DETAIL"

**Visual 1: Personnel Table**
1. Insert → **Table**
2. Columns:
   - `silver_personnel_readiness[UnitName]`
   - `silver_personnel_readiness[Brigade]`
   - `silver_personnel_readiness[PersonnelAssigned]`
   - `silver_personnel_readiness[PersonnelPresent]`
   - `silver_personnel_readiness[PersonnelPresentPct]`
   - `silver_personnel_readiness[ReadinessScore]`
   - `silver_personnel_readiness[ReadinessStatus]`
3. Format: Conditional formatting on ReadinessStatus column (GREEN/AMBER/RED)

**Visual 2: Personnel Present % by Unit (Bar Chart)**
1. Insert → **Bar chart**
2. Y-axis: `silver_personnel_readiness[UnitName]`
3. X-axis: `silver_personnel_readiness[PersonnelPresentPct]` (Average)
4. Add data label

**Visual 3: Readiness Category Distribution (Pie Chart)**
1. Insert → **Pie chart**
2. Legend: `silver_personnel_readiness[ReadinessCategory]`
3. Values: Count of UnitID

**Add Slicers:**
1. Insert → **Slicer**
2. Field: `silver_personnel_readiness[Division]`
3. Format as dropdown or list

4. Insert → **Slicer**
5. Field: `silver_personnel_readiness[ReportDate]`
6. Format as date range slider

### **Exercise 6.4: Create Report Page 3 - Equipment Readiness Detail**

1. Click **+ New page**
2. Add page title: "EQUIPMENT READINESS DETAIL"

**Visual 1: Equipment Summary by Type (Matrix)**
1. Insert → **Matrix**
2. Rows: `silver_equipment_inventory[EquipmentType]`
3. Columns: `silver_equipment_inventory[ConditionStatus]`
4. Values: `[Total Equipment]`

**Visual 2: Equipment by Unit (Table)**
1. Insert → **Table**
2. Columns:
   - `gold_equipment_by_unit[UnitName]`
   - `gold_equipment_by_unit[EquipmentType]`
   - `gold_equipment_by_unit[TotalEquipment]`
   - `gold_equipment_by_unit[TotalOperational]`
   - `gold_equipment_by_unit[TotalMaintenance]`
   - `gold_equipment_by_unit[AvgOperationalPct]`

**Visual 3: Inspection Status (Stacked Column Chart)**
1. Insert → **Stacked column chart**
2. X-axis: `silver_equipment_inventory[EquipmentType]`
3. Y-axis: Count of EquipmentID
4. Legend: `silver_equipment_inventory[InspectionStatus]`

**Visual 4: Operational % by Equipment Type (Gauge)**
1. Insert → **Gauge** (repeat for major equipment types)
2. Value: `[Equipment Readiness %]`
3. Filter to specific equipment type
4. Min: 0, Max: 100, Target: 90

### **Exercise 6.5: Create Report Page 4 - Training Metrics**

1. Click **+ New page**
2. Add page title: "TRAINING METRICS"

**Visual 1: Training Completion by Unit (Clustered Bar)**
1. Insert → **Clustered bar chart**
2. Y-axis: `silver_training_metrics[UnitID]`
3. X-axis: 
   - `silver_training_metrics[ParticipantsScheduled]` (Sum)
   - `silver_training_metrics[ParticipantsCompleted]` (Sum)
4. Legend: Automatically created

**Visual 2: Training Details (Table)**
1. Insert → **Table**
2. Columns:
   - `silver_training_metrics[UnitID]`
   - `silver_training_metrics[TrainingType]`
   - `silver_training_metrics[TrainingName]`
   - `silver_training_metrics[CompletionRate]`
   - `silver_training_metrics[PassRate]`
   - `silver_training_metrics[AverageScore]`
   - `silver_training_metrics[TrainingEffectiveness]`

**Visual 3: Training Effectiveness Distribution (Funnel)**
1. Insert → **Funnel chart**
2. Category: `silver_training_metrics[TrainingEffectiveness]`
3. Values: Count of TrainingID

**Visual 4: Pass Rate vs Completion Rate (Scatter Chart)**
1. Insert → **Scatter chart**
2. X-axis: `silver_training_metrics[CompletionRate]`
3. Y-axis: `silver_training_metrics[PassRate]`
4. Legend: `silver_training_metrics[TrainingType]`
5. Size: `silver_training_metrics[ParticipantsCompleted]`

### **Exercise 6.6: Format and Publish Report**

1. Apply a consistent theme:
   - View → Themes → Select a professional theme (e.g., "Executive")

2. Add report-level filters (applies to all pages):
   - Filters pane → Add `silver_personnel_readiness[Division]`
   - Add `silver_personnel_readiness[ReportDate]`

3. Add navigation buttons:
   - Insert → Button → Navigator → Page navigator
   - Format and position on each page

4. **Save the report:**
   - File → Save
   - Name: `Army_Unit_Readiness_Report`

5. **Publish to workspace:**
   - The report is automatically saved to your workspace

---

## **Part 7: Automation and Scheduling (15 minutes)**

### **Exercise 7.1: Schedule Pipeline Refresh**

1. Navigate to your workspace
2. Find `Pipeline_Ingest_Readiness_Data`
3. Click the **...** (More options) → **Settings**
4. Under **Scheduled refresh**, click **Add schedule**
5. Configure:
   - **Frequency**: Daily
   - **Time**: 0600 (6:00 AM)
   - **Time zone**: Your local time zone
6. Click **Apply**

> **Note**: In a real scenario, your source data would be updated regularly (e.g., from SQL databases, APIs). The pipeline would automatically pull the latest data.

### **Exercise 7.2: Schedule Notebook Execution**

1. Navigate to `Transform_Readiness_Data` notebook
2. Click **Run** → **Schedule**
3. Configure:
   - **Schedule name**: `Daily_Transform_0630`
   - **Start**: Today's date
   - **Frequency**: Daily at 06:30
   - **Time zone**: Your local time zone
4. Click **Save**

This ensures your transformations run 30 minutes after data ingestion.

### **Exercise 7.3: Set Semantic Model Refresh**

1. Navigate to `ArmyReadinessSemanticModel`
2. Click **Settings** (gear icon)
3. Under **Scheduled refresh**:
   - Toggle **Keep your data up to date** to **On**
   - **Refresh frequency**: Daily
   - **Time**: 07:00 (after pipeline and notebook complete)
4. Click **Apply**

> **✅ Checkpoint**: Your entire data pipeline is now automated! Data will refresh daily without manual intervention.

---

## **Part 8: Advanced Features (Optional - 30 minutes)**

### **Exercise 8.1: Add Row-Level Security (RLS)**

Row-level security ensures users only see data for their division.

1. Navigate to `ArmyReadinessSemanticModel`
2. Click **Model view**
3. Click **Modeling** → **Manage roles**
4. Click **Create role**
5. Role name: `1st_Infantry_Division`
6. Select table: `silver_personnel_readiness`
7. Add DAX filter:
   ```dax
   [Division] = "1st Infantry Division"
   ```
8. Click **Save**

9. Repeat for other divisions:
   - `82nd_Airborne_Division`

**Test RLS:**
1. Click **Modeling** → **View as**
2. Select role: `1st_Infantry_Division`
3. Click **OK**
4. Verify only 1st Infantry Division data appears

### **Exercise 8.2: Create Data Activator Alert**

Data Activator can send alerts when readiness drops below thresholds.

1. From your report, right-click on the **Readiness %** card
2. Select **Set alert**
3. Configure:
   - **Condition**: When readiness % drops below 85
   - **Action**: Send email to commander
   - **Recipients**: Your email
4. Click **Create**

### **Exercise 8.3: Add Natural Language Q&A**

1. Edit your report
2. Insert → **Q&A** visual
3. Users can now ask questions like:
   - "What is the average readiness score by brigade?"
   - "Show me units with RED status"
   - "Which equipment type has the lowest operational percentage?"

---

## **Lab Summary and Key Takeaways**

### **What You Accomplished:**

✅ **Data Ingestion**: Created a data pipeline to load CSV files into Lakehouse Delta tables

✅ **Data Transformation**: Used notebooks (PySpark) to transform raw data into curated Silver and Gold layers

✅ **Data Modeling**: Built a semantic model with relationships and DAX measures

✅ **Visualization**: Created a comprehensive 4-page Power BI report with executive dashboards and detailed analytics

✅ **Automation**: Scheduled automated refreshes for the entire pipeline

✅ **Advanced Features**: Implemented Row-Level Security for data governance

### **Microsoft Fabric Benefits for Army Operations:**

1. **Unified Platform**: All data, analytics, and reporting in one place - no need for separate tools
2. **Scalability**: F32 capacity can handle massive datasets from multiple installations
3. **Real-time Insights**: Near real-time dashboards for operational decision-making
4. **Collaboration**: Share reports and datasets across units and commands
5. **Security**: Enterprise-grade security with RLS and data encryption
6. **Cost-Effective**: Capacity-based pricing model vs. per-user licensing

### **Real-World Applications:**

- **Command Readiness Reports**: Daily/weekly readiness briefings for leadership
- **Predictive Maintenance**: Identify equipment needing maintenance before failure
- **Training Optimization**: Analyze training effectiveness and optimize schedules
- **Resource Allocation**: Data-driven decisions on personnel and equipment distribution
- **Compliance Reporting**: Automated regulatory and inspection compliance reports

### **Next Steps:**

1. **Expand Data Sources**: Integrate with Army enterprise systems (SQL databases, APIs)
2. **Add More Metrics**: Include supply chain, logistics, mission readiness
3. **Mobile Reports**: Publish to Power BI Mobile for field commanders
4. **AI/ML Models**: Use Fabric to build predictive models for maintenance, attrition
5. **Real-Time Streaming**: Implement real-time data streams for tactical operations

---

## **Appendix A: Sample Data Schema**

### **personnel_readiness.csv**
| Column | Data Type | Description |
|--------|-----------|-------------|
| UnitID | String | Unique unit identifier |
| UnitName | String | Unit designation |
| Brigade | String | Parent brigade |
| Division | String | Parent division |
| PersonnelAssigned | Integer | Total assigned personnel |
| PersonnelPresent | Integer | Personnel currently present |
| ReadinessStatus | String | GREEN/AMBER/RED status |
| ReportDate | Date | Date of report |
| MOS | String | Military Occupational Specialty |
| ReadinessScore | Decimal | Numerical readiness score (0-100) |

### **equipment_inventory.csv**
| Column | Data Type | Description |
|--------|-----------|-------------|
| EquipmentID | String | Unique equipment identifier |
| EquipmentType | String | Category (Vehicle, Weapon, Communications) |
| EquipmentName | String | Specific equipment model |
| UnitID | String | Assigned unit |
| Quantity | Integer | Total quantity |
| OperationalQty | Integer | Operational units |
| MaintenanceQty | Integer | Units in maintenance |
| NonOperationalQty | Integer | Non-operational units |
| LastInspectionDate | Date | Last inspection date |
| NextInspectionDate | Date | Next scheduled inspection |
| ConditionStatus | String | SERVICEABLE/NEEDS_ATTENTION |

### **training_metrics.csv**
| Column | Data Type | Description |
|--------|-----------|-------------|
| TrainingID | String | Unique training event ID |
| UnitID | String | Unit that conducted training |
| TrainingType | String | Category of training |
| TrainingName | String | Specific training event |
| ScheduledDate | Date | Scheduled training date |
| CompletedDate | Date | Actual completion date |
| ParticipantsScheduled | Integer | Scheduled participants |
| ParticipantsCompleted | Integer | Actual participants |
| PassRate | Decimal | Percentage who passed (0-100) |
| AverageScore | Decimal | Average test/qualification score |
| TrainingStatus | String | COMPLETED/SCHEDULED/CANCELLED |

---

## **Appendix B: Useful SQL Queries**

Query the Lakehouse using SQL Analytics Endpoint:

**Check current readiness status:**
```sql
SELECT 
    Division,
    Brigade,
    UnitName,
    ReadinessStatus,
    ReadinessScore,
    PersonnelPresentPct
FROM silver_personnel_readiness
WHERE ReportDate = (SELECT MAX(ReportDate) FROM silver_personnel_readiness)
ORDER BY ReadinessScore DESC;
```

**Find units with low equipment readiness:**
```sql
SELECT 
    u.UnitName,
    e.EquipmentType,
    e.OperationalPct,
    e.ConditionStatus
FROM silver_equipment_inventory e
JOIN silver_personnel_readiness u ON e.UnitID = u.UnitID
WHERE e.OperationalPct < 80
ORDER BY e.OperationalPct;
```

**Training completion summary:**
```sql
SELECT 
    TrainingType,
    COUNT(*) AS TotalEvents,
    AVG(CompletionRate) AS AvgCompletionRate,
    AVG(PassRate) AS AvgPassRate
FROM silver_training_metrics
WHERE TrainingStatus = 'COMPLETED'
GROUP BY TrainingType
ORDER BY AvgPassRate DESC;
```

---

## **Appendix C: Troubleshooting Guide**

### **Issue: Pipeline fails to copy data**
- **Solution**: Check file paths are correct, verify CSV format (UTF-8 encoding)

### **Issue: Notebook can't find table**
- **Solution**: Ensure Lakehouse is attached to notebook, refresh table list

### **Issue: Semantic model shows no data**
- **Solution**: Check relationships are correctly defined, verify table names

### **Issue: Report visuals are blank**
- **Solution**: Ensure semantic model has been refreshed, check filters aren't excluding all data

### **Issue: Scheduled refresh fails**
- **Solution**: Verify workspace capacity is running, check pipeline/notebook logs

---

## **Appendix D: Resources and References**

- **Microsoft Fabric Documentation**: https://learn.microsoft.com/fabric/
- **Power BI Documentation**: https://learn.microsoft.com/power-bi/
- **DAX Reference**: https://dax.guide/
- **Fabric Community**: https://community.fabric.microsoft.com/
- **Power BI Training**: https://learn.microsoft.com/training/powerplatform/power-bi

---

## **Appendix E: Glossary of Terms**

- **Lakehouse**: Unified data platform combining data lake and data warehouse
- **Delta Lake**: Open-source storage layer providing ACID transactions
- **Bronze/Silver/Gold**: Data quality layers (Raw/Cleansed/Curated)
- **Semantic Model**: Business logic layer defining relationships and calculations
- **DAX**: Data Analysis Expressions - formula language for Power BI
- **PySpark**: Python API for Apache Spark
- **Dataflow Gen2**: Low-code ETL tool using Power Query
- **F32 Capacity**: Fabric compute capacity unit

---

**END OF LAB GUIDE**

---

**Prepared for: US Army Customer**  
**Lab Environment: Microsoft Fabric F32 Capacity**  
**Version: 1.0**  
**Date: November 2025**

**UNCLASSIFIED // FOR TRAINING USE ONLY**
