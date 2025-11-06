# Microsoft Fabric Lab: Army Unit Readiness Analytics
## Lab Guide for US Army Operations

---

## **Lab Overview**

**Objective**: Build an end-to-end analytics solution in Microsoft Fabric to track and analyze Army unit readiness metrics.

**Duration**: Approximately 1-2 hours

**Scenario**: You are a data analyst supporting Army operations. Your mission is to integrate personnel readiness, equipment inventory, and training metrics data to provide commanders with actionable insights on unit readiness status.

**What You'll Learn**:
- Ingest data into a Fabric Lakehouse using Data Pipelines
- Transform data using Dataflow Gen2 (Power Query)
- Create a semantic model for reporting
- Build Power BI reports for operational dashboards

**Prerequisites**:
- Access to Microsoft Fabric workspace with F32 capacity
- Basic understanding of SQL and data concepts
- Familiarity with Power BI

---

## **Lab Architecture**

```
CSV Data Sources (GitHub)
    ↓
Data Pipeline (Orchestration)
    ↓
Dataflow Gen2 (Web Connector + Power Query Transformations)
    ↓
Lakehouse Tables (Bronze/Silver/Gold)
    ↓
Semantic Model
    ↓
Power BI Report
```

---

## **Part 1: Environment Setup (10 minutes)**

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

> **Note**: The Lakehouse is built on Delta Lake and provides ACID transactions, scalability, and unified batch/streaming processing.

---

## **Part 2: Create Data Pipeline for Ingestion (15 minutes)**

### **Exercise 2.1: Get Sample Data from GitHub**

For this lab, we'll use three CSV files representing Army operational data hosted on GitHub:

1. **personnel_readiness.csv** - Unit personnel status and readiness scores
2. **equipment_inventory.csv** - Equipment condition and maintenance status  
3. **training_metrics.csv** - Training completion and performance data

**GitHub Data Sources:**

The CSV files are available at these URLs:
- Personnel: `https://raw.githubusercontent.com/rizwanh-MFST/Fabric_Practice/refs/heads/main/sample-data/personnel_readiness.csv`
- Equipment: `https://raw.githubusercontent.com/rizwanh-MFST/Fabric_Practice/refs/heads/main/sample-data/equipment_inventory.csv`
- Training: `https://raw.githubusercontent.com/rizwanh-MFST/Fabric_Practice/refs/heads/main/sample-data/training_metrics.csv`

> **💡 Note**: We'll load these files directly in the Dataflow Gen2 using the Web connector. No manual uploads required!

### **Exercise 2.2: Create a Data Pipeline**

1. Navigate to your workspace: `Army_Readiness_Analytics`
2. Click **+ New** → **Data Pipeline**
3. Name it: `Ingest_Army_Data`
4. Click **Create**

The pipeline will orchestrate our data ingestion and transformation processes.

> **✅ Checkpoint**: You now have a pipeline ready, and we'll connect to the GitHub data sources in the next section!

---

## **Part 3: Data Transformation with Dataflow Gen2 (45 minutes)**

### **Exercise 3.1: Create Dataflow Gen2**

1. Navigate to your workspace: `Army_Readiness_Analytics`
2. Click **+ New** → **Dataflow Gen2**
3. The Power Query editor will open

> **💡 Tip**: Dataflow Gen2 uses Power Query (the same transformation engine as Power BI) to create reusable ETL logic with a visual, low-code interface.

### **Exercise 3.2: Load Personnel Data from GitHub (Bronze Layer)**

1. In the Power Query editor, click **Get data**
2. Search for and select **Web** → Click **Next**
3. In the URL field, paste:
   ```
   https://raw.githubusercontent.com/rizwanh-MFST/Fabric_Practice/refs/heads/main/sample-data/personnel_readiness.csv
   ```
4. Click **OK**
5. Power Query will connect and preview the data
6. If prompted for authentication, select **Anonymous** → Click **Connect**

**Configure the Bronze query:**

7. In the **Query settings** pane (right side), rename the query to: `bronze_personnel_readiness`
8. Verify column types are correct (Power Query auto-detects types)
9. Click **Add data destination** (bottom right)
10. Select **Lakehouse**
11. Choose `ArmyReadinessLakehouse`
12. Select **New table**
13. Table name: `bronze_personnel_readiness`
14. Click **Next** → **Save settings**

> **✅ Bronze Layer Complete**: You've created a query that loads CSV data from GitHub to a Bronze table.

### **Exercise 3.3: Transform Personnel Data (Silver Layer)**

Now we'll create a Silver layer with calculated columns:

1. **Right-click** on `bronze_personnel_readiness` query → **Reference**
2. A new query is created - rename it to: `silver_personnel_readiness`
3. Apply the following transformations:

**Add Calculated Columns:**

4. Click **Add column** → **Custom column**
   - **New column name**: `PersonnelPresentPct`
   - **Formula**: `= [PersonnelPresent] / [PersonnelAssigned] * 100`
   - Click **OK**

5. Right-click the `PersonnelPresentPct` column → **Change type** → **Decimal number**
6. Right-click `PersonnelPresentPct` → **Transform** → **Round** → **Decimal places**: 2

7. Click **Add column** → **Custom column**
   - **New column name**: `PersonnelAbsent`
   - **Formula**: `= [PersonnelAssigned] - [PersonnelPresent]`
   - Click **OK**

8. Right-click the `PersonnelAbsent` column → **Change type** → **Whole number**

9. Click **Add column** → **Conditional column**
   - **New column name**: `ReadinessCategory`
   - **If** `ReadinessScore` **is greater than or equal to** `95` **then** `Excellent`
   - **Add clause**: **else if** `ReadinessScore` **is greater than or equal to** `90` **then** `Good`
   - **Add clause**: **else if** `ReadinessScore` **is greater than or equal to** `85` **then** `Satisfactory`
   - **Otherwise**: `Needs Improvement`
   - Click **OK**

**Add data destination for Silver:**

9. Click **Add data destination** (bottom right)
10. Select **Lakehouse** → Choose `ArmyReadinessLakehouse`
11. Select **New table** → Table name: `silver_personnel_readiness`
12. Click **Next** → **Save settings**

> **✅ Silver Layer Complete**: Personnel data is now enriched with calculated metrics!

### **Exercise 3.4: Load and Transform Equipment Data**

**Create Bronze Equipment Query:**

1. Click **Get data** → **Web**
2. Paste URL:
   ```
   https://raw.githubusercontent.com/rizwanh-MFST/Fabric_Practice/refs/heads/main/sample-data/equipment_inventory.csv
   ```
3. Click **OK** → If prompted, select **Anonymous** → **Connect**
4. Rename query to: `bronze_equipment_inventory`
5. Add destination: Lakehouse → `ArmyReadinessLakehouse` → New table: `bronze_equipment_inventory`

**Create Silver Equipment Query:**

6. Right-click `bronze_equipment_inventory` → **Reference**
7. Rename to: `silver_equipment_inventory`

**Add transformations:**

8. **Add column** → **Custom column**
   - Name: `OperationalPct`
   - Formula: `= [OperationalQty] / [Quantity] * 100`
   - Change type to Decimal, Round to 2 places

9. **Add column** → **Custom column**
   - Name: `DaysUntilInspection`
   - Formula: `= Duration.Days(DateTime.From([NextInspectionDate]) - DateTime.LocalNow())`
   - Change type to Whole number

10. **Add column** → **Conditional column**
    - Name: `InspectionStatus`
    - If `DaysUntilInspection` **is less than** `0` then `Overdue`
    - else if `DaysUntilInspection` **is less than or equal to** `7` then `Due Soon`
    - Otherwise: `Current`

11. Add destination: Lakehouse → New table: `silver_equipment_inventory`

### **Exercise 3.5: Load and Transform Training Data**

**Create Bronze Training Query:**

1. Click **Get data** → **Web**
2. Paste URL:
   ```
   https://raw.githubusercontent.com/rizwanh-MFST/Fabric_Practice/refs/heads/main/sample-data/training_metrics.csv
   ```
3. Click **OK** → If prompted, select **Anonymous** → **Connect**
4. Rename query to: `bronze_training_metrics`
5. Add destination: New table: `bronze_training_metrics`

**Create Silver Training Query:**

6. Right-click `bronze_training_metrics` → **Reference**
7. Rename to: `silver_training_metrics`

**Add transformations:**

8. **Add column** → **Custom column**
   - Name: `CompletionRate`
   - Formula: `= [ParticipantsCompleted] / [ParticipantsScheduled] * 100`
   - Change type to Decimal, Round to 2 places

8. **Add column** → **Custom column**
   - Name: `TrainingEffectiveness`
   - Formula: `if [PassRate] >= 95 and [CompletionRate] >= 95 then "Highly Effective" else if [PassRate] >= 90 and [CompletionRate] >= 90 then "Effective" else "Needs Improvement"`
   - Click **OK**

9. Add destination: Lakehouse → New table: `silver_training_metrics`

### **Exercise 3.6: Create Gold Layer Summary**

**Create Gold Aggregation Query:**

1. Right-click `silver_personnel_readiness` → **Reference**
2. Rename to: `gold_unit_readiness_summary`

**Add aggregation:**

3. Select columns: `UnitID`, `UnitName`, `Brigade`, `Division`
4. Click **Transform** tab → **Group by**
5. Configure grouping:
   - **Group by**: `UnitID`, `UnitName`, `Brigade`, `Division`
   - **New column name**: `AvgReadinessScore`
     - **Operation**: Average
     - **Column**: `ReadinessScore`
   - **Add aggregation**: 
     - **New column name**: `AvgPersonnelPresent`
     - **Operation**: Average
     - **Column**: `PersonnelPresentPct`
   - **Add aggregation**:
     - **New column name**: `ReportCount`
     - **Operation**: Count rows
6. Click **OK**

7. **Add column** → **Conditional column**
   - Name: `OverallReadiness`
   - If `AvgReadinessScore` **is greater than or equal to** `95` then `GREEN`
   - else if `AvgReadinessScore` **is greater than or equal to** `90` then `AMBER`
   - Otherwise: `RED`

8. Add destination: Lakehouse → New table: `gold_unit_readiness_summary`

### **Exercise 3.7: Save and Run the Dataflow**

1. Review all queries in the **Queries pane** (left side):
   - ✅ bronze_personnel_readiness
   - ✅ silver_personnel_readiness
   - ✅ bronze_equipment_inventory
   - ✅ silver_equipment_inventory
   - ✅ bronze_training_metrics
   - ✅ silver_training_metrics
   - ✅ gold_unit_readiness_summary

2. Click **Save & run** (bottom left) or use the dropdown for other save options
3. Give your dataflow a name if prompted (e.g., `Army_Readiness_Dataflow`)
4. Wait for the dataflow to save and run (~1-2 minutes)
5. Monitor the refresh status - you'll see progress indicators for each query
6. Once complete, the dataflow will have loaded data to all Bronze, Silver, and Gold tables in the Lakehouse

> **✅ Checkpoint**: Your Dataflow Gen2 has created Bronze, Silver, and Gold tables in the Lakehouse!

### **Exercise 3.8: Add Dataflow to Pipeline**

1. Navigate to your `Ingest_Army_Data` pipeline
2. In the pipeline canvas, click **Activities** → **Dataflow**
3. Drag the **Dataflow** activity to the canvas
4. In the **Settings** tab:
   - **Dataflow**: Select your Dataflow Gen2
5. **Save** the pipeline
6. Click **Run** to execute the pipeline

> **💡 What just happened?** The pipeline now orchestrates the Dataflow, making it easy to schedule regular data refreshes!

---

## **Part 4: Create Semantic Model (15 minutes)**

### **Exercise 4.1: Create Semantic Model**

1. Navigate to `ArmyReadinessLakehouse`
2. Click **SQL analytics endpoint** (at the top of the lakehouse)
3. Click **New semantic model** button at the top
4. Name it: `ArmyReadinessSemanticModel`
5. Select the following tables:
   - ✅ `gold_unit_readiness_summary` (main fact table)
   - ✅ `silver_personnel_readiness` (for personnel details)
   - ✅ `silver_equipment_inventory` (for equipment details)
   - ✅ `silver_training_metrics` (for training details)
6. Click **Confirm**

> **💡 Architecture Note**: The Gold table serves as our main aggregated fact table. We include Silver tables for detailed personnel, equipment, and training analysis.

### **Exercise 4.2: Define Relationships**

1. The semantic model will open in model view
2. Create relationships by dragging fields between tables:

**Relationship 1: Gold → Personnel**
- From: `gold_unit_readiness_summary[UnitID]`
- To: `silver_personnel_readiness[UnitID]`
- Cardinality: **One-to-Many** (one unit can have many personnel reports)
- Cross filter direction: Both

**Relationship 2: Gold → Equipment**
- From: `gold_unit_readiness_summary[UnitID]`
- To: `silver_equipment_inventory[UnitID]`
- Cardinality: **One-to-Many** (one unit can have many equipment items)
- Cross filter direction: Both

**Relationship 3: Gold → Training**
- From: `gold_unit_readiness_summary[UnitID]`
- To: `silver_training_metrics[UnitID]`
- Cardinality: **One-to-Many** (one unit can have many training events)
- Cross filter direction: Both

> **✅ Clean Model**: By using Gold as the primary table with one-to-many relationships, we avoid many-to-many complexity and improve performance!

### **Exercise 4.3: Create Key DAX Measures**

1. Click on `gold_unit_readiness_summary` table
2. Click **New measure** in the ribbon
3. Add these essential DAX measures:

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

**Measure 9: Avg Training Pass Rate**
```dax
Avg Training Pass Rate = AVERAGE(silver_training_metrics[PassRate])
```

**Measure 10: Avg Completion Rate**
```dax
Avg Completion Rate = AVERAGE(silver_training_metrics[CompletionRate])
```

6. Click **Save** to save the semantic model

> **✅ Checkpoint**: Your semantic model is ready with relationships and key measures!

---

## **Part 5: Build Power BI Report (20 minutes)**

### **Exercise 5.1: Create Report and Add KPI Cards**

1. From the semantic model page, click **Create report** button
2. This opens Power BI in edit mode

**Add Report Title:**
1. Insert → Text box
2. Type: "ARMY UNIT READINESS DASHBOARD"
3. Format: Font size 24, Bold, Background color: Dark blue, Font color: White

**Add 3 Key Metric Cards:**

**Card 1: Total Units**
1. Insert → Card
2. Drag `[Total Units]` to the card
3. Format callout value size to 48pt

**Card 2: Readiness %**
1. Insert → Card  
2. Drag `[Readiness %]` to the card
3. Format to show 1 decimal place

**Card 3: Equipment Readiness %**
1. Insert → Card
2. Drag `[Equipment Readiness %]` to the card
3. Format to show 1 decimal place

### **Exercise 5.2: Add Key Visuals**

**Visual 1: Readiness by Division (Stacked Bar Chart)**
1. Insert → Stacked bar chart
2. **Legend** (add this FIRST): `gold_unit_readiness_summary[OverallReadiness]`
3. **Y-axis**: `gold_unit_readiness_summary[Division]`
4. **X-axis**: `gold_unit_readiness_summary[UnitID]` (Count Distinct)
5. Format data colors: GREEN = Green, AMBER = Yellow, RED = Red
6. Title: "Unit Readiness Status by Division"

> **💡 Tip**: Add the Legend field first before the axes - this helps Power BI establish the correct grouping. If a division still doesn't appear, verify the gold_unit_readiness_summary table has data for both divisions.

**Visual 2: Readiness Trend (Line Chart)**
1. Insert → Line chart
2. X-axis: `silver_personnel_readiness[ReportDate]`
3. Y-axis: `silver_personnel_readiness[ReadinessScore]` (Average)
4. Legend: `silver_personnel_readiness[Brigade]`
5. Title: "Readiness Score Trend"

**Visual 3: Equipment Status (Donut Chart)**
1. Insert → Donut chart
2. Legend: `silver_equipment_inventory[ConditionStatus]`
3. Values: `[Total Equipment]`
4. Title: "Equipment Condition Status"

**Visual 4: Training Performance (Column Chart)**
1. Insert → Clustered column chart
2. X-axis: `silver_training_metrics[TrainingType]`
3. Y-axis: `[Avg Training Pass Rate]`
4. Title: "Training Pass Rates by Type"

**Visual 5: Unit Details (Table)**
1. Insert → Table
2. Add columns:
   - `gold_unit_readiness_summary[UnitName]`
   - `gold_unit_readiness_summary[Division]`
   - `gold_unit_readiness_summary[AvgReadinessScore]`
   - `gold_unit_readiness_summary[OverallReadiness]`
3. Add conditional formatting to `OverallReadiness` column (background colors)

### **Exercise 5.3: Add Interactivity and Publish**

**Add Slicers:**
1. Insert → Slicer
2. Add `silver_personnel_readiness[Division]` (dropdown style)
3. Position in top right corner

**Publish Report:**
1. File → Save
2. Name: `Army_Unit_Readiness_Report`
3. Report is automatically published to your workspace

> **✅ Checkpoint**: You now have a fully functional Power BI report!

---

## **Part 6: Automation (Optional - 10 minutes)**

### **Exercise 6.1: Schedule Pipeline Refresh**

1. Navigate to your workspace: `Army_Readiness_Analytics`
2. Find the `Ingest_Army_Data` pipeline
3. Click **...** (More options) → **Settings**
4. Under **Scheduled refresh**, toggle to **On**
5. Configure:
   - **Frequency**: Daily
   - **Time**: 06:00 (6:00 AM)
   - **Time zone**: Your local time zone
6. Click **Apply**

> **💡 Note**: The pipeline will automatically run the Dataflow Gen2, which loads and transforms all data into Bronze, Silver, and Gold tables.

### **Exercise 6.2: Configure Semantic Model Refresh**

1. Navigate to `ArmyReadinessSemanticModel`
2. Click **Settings** (gear icon)
3. Under **Scheduled refresh**:
   - Toggle to **On**
   - Frequency: Daily at 07:00 (after pipeline completes)
4. Click **Apply**

> **💡 Tip**: The pipeline runs first to refresh data via Dataflow Gen2, then the semantic model refreshes to pull the latest data into Power BI.

---

## **Lab Summary and Key Takeaways**

### **What You Accomplished:**

✅ **Data Ingestion**: Loaded CSV files from GitHub into Lakehouse Bronze tables using Dataflow Gen2

✅ **Data Transformation**: Used Dataflow Gen2 (Power Query) to transform raw data into curated Silver and Gold layers

✅ **Data Modeling**: Built a semantic model with relationships and DAX measures

✅ **Visualization**: Created a Power BI dashboard with KPIs and interactive visuals

✅ **Automation**: (Optional) Scheduled automated refreshes for pipeline and semantic model

### **Microsoft Fabric Benefits for Army Operations:**

1. **Unified Platform**: All data, analytics, and reporting in one place
2. **Scalability**: F32 capacity can handle large datasets from multiple installations
3. **Real-time Insights**: Near real-time dashboards for operational decision-making
4. **Collaboration**: Share reports across units and commands
5. **Security**: Enterprise-grade security with RLS capability

### **Next Steps:**

1. **Expand Data Sources**: Integrate with SQL databases or REST APIs
2. **Add More Metrics**: Include supply chain, logistics, mission readiness
3. **Mobile Reports**: Publish to Power BI Mobile for field access
4. **Advanced Analytics**: Add predictive models using Fabric Data Science

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

## **Appendix B: Troubleshooting Guide**

### **Issue: Dataflow Gen2 can't connect to GitHub URLs**
- **Solution**: Verify GitHub raw URLs are correct, ensure Anonymous authentication is selected, check internet connectivity

### **Issue: Web connector shows authentication errors**
- **Solution**: Select "Anonymous" authentication when connecting to GitHub raw URLs, do not use other auth methods

### **Issue: Semantic model shows no data**
- **Solution**: Check relationships are correctly defined, manually refresh semantic model

### **Issue: Report visuals are blank**
- **Solution**: Ensure semantic model refreshed, check filters aren't excluding all data

---

## **Appendix C: Resources and References**

- **Microsoft Fabric Documentation**: https://learn.microsoft.com/fabric/
- **Lakehouse Tutorial**: https://learn.microsoft.com/fabric/data-engineering/tutorial-lakehouse-introduction
- **Power BI Documentation**: https://learn.microsoft.com/power-bi/
- **DAX Reference**: https://dax.guide/
- **Fabric Community**: https://community.fabric.microsoft.com/

---

**END OF LAB GUIDE**

---

**Prepared for: US Army Customer**  
**Lab Environment: Microsoft Fabric F32 Capacity**  
**Version: 2.0 - Streamlined (1-2 hours)**  
**Date: November 2025**

**UNCLASSIFIED // FOR TRAINING USE ONLY**

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
2. Find `Ingest_Army_Data`
3. Click the **...** (More options) → **Settings**
4. Under **Scheduled refresh**, toggle to **On**
5. Configure:
   - **Frequency**: Daily
   - **Time**: 0600 (6:00 AM)
   - **Time zone**: Your local time zone
6. Click **Apply**

> **Note**: The pipeline orchestrates the Dataflow Gen2, which loads and transforms all data from GitHub into Bronze, Silver, and Gold tables.

### **Exercise 7.2: Set Semantic Model Refresh**

1. Navigate to `ArmyReadinessSemanticModel`
2. Click **Settings** (gear icon)
3. Under **Scheduled refresh**:
   - Toggle **Keep your data up to date** to **On**
   - **Refresh frequency**: Daily
   - **Time**: 07:00 (after pipeline completes)
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

✅ **Data Ingestion**: Created a data pipeline to orchestrate Dataflow Gen2 for loading CSV files from GitHub

✅ **Data Transformation**: Used Dataflow Gen2 (Power Query) to transform raw data into curated Silver and Gold layers

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

### **Issue: Pipeline fails to run**
- **Solution**: Check that Dataflow Gen2 is published, verify workspace capacity is active

### **Issue: Dataflow Gen2 errors during refresh**
- **Solution**: Verify GitHub URLs are accessible, check Anonymous authentication is selected, review query transformations for errors

### **Issue: Semantic model shows no data**
- **Solution**: Check relationships are correctly defined, manually refresh semantic model, verify Dataflow Gen2 completed successfully

### **Issue: Report visuals are blank**
- **Solution**: Ensure semantic model has been refreshed, check filters aren't excluding all data

### **Issue: Scheduled refresh fails**
- **Solution**: Verify workspace capacity is running, check pipeline and Dataflow Gen2 logs for errors

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
- **Dataflow Gen2**: Low-code ETL tool using Power Query
- **Power Query**: Visual data transformation engine (M language)
- **F32 Capacity**: Fabric compute capacity unit

---

**END OF LAB GUIDE**

---

**Prepared for: US Army Customer**  
**Lab Environment: Microsoft Fabric F32 Capacity**  
**Version: 1.0**  
**Date: November 2025**

**UNCLASSIFIED // FOR TRAINING USE ONLY**

