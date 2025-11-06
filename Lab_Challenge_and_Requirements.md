# Army Unit Readiness Analytics - Lab Challenge

## 🎯 Executive Summary

You are a data analyst supporting Army operations at the division level. Your mission is to build an analytics solution in Microsoft Fabric that provides commanders with real-time visibility into unit readiness across personnel, equipment, and training domains.

---

## 📋 The Challenge

### **Situation**

The Army needs a unified readiness dashboard to monitor 10 units across 2 divisions (1st Infantry Division and 82nd Airborne Division). Currently, readiness data is scattered across three separate CSV files:

1. **Personnel Readiness Data** - Unit manning levels and readiness scores
2. **Equipment Inventory Data** - Equipment quantities and operational status
3. **Training Metrics Data** - Training completion rates and effectiveness

Command leadership requires a **single source of truth** to:
- Identify units requiring immediate attention
- Track readiness trends over time
- Make data-driven resource allocation decisions
- Support briefings and status reports

### **Your Mission**

Build an end-to-end analytics solution using Microsoft Fabric that:
1. **Ingests** data from CSV files into a cloud data platform
2. **Transforms** raw data into actionable insights using Bronze/Silver/Gold architecture
3. **Models** data for analytical consumption
4. **Visualizes** key metrics in an executive dashboard

---

## 🎖️ Success Criteria

### **Technical Requirements**

#### 1. **Data Platform (Lakehouse)**
- ✅ Create a Fabric Lakehouse named `ArmyReadinessLakehouse`
- ✅ Use GitHub-hosted CSV files via Web connector
- ✅ Implement medallion architecture (Bronze/Silver/Gold)

#### 2. **Data Integration (Pipeline + Dataflow)**
- ✅ Create a Data Pipeline named `Ingest_Army_Data`
- ✅ Create a Dataflow Gen2 with Power Query transformations
- ✅ Load raw CSVs to Bronze tables (3 tables)
- ✅ Transform Bronze → Silver with calculated columns (3 tables)
- ✅ Create Gold layer aggregation (1 summary table)
- ✅ Orchestrate Dataflow execution within Pipeline

#### 3. **Data Transformations Required**

**Bronze Layer (Raw Data):**
- Bronze table: `bronze_personnel_readiness`
- Bronze table: `bronze_equipment_inventory`
- Bronze table: `bronze_training_metrics`

**Silver Layer (Cleansed + Calculated Columns):**

For `silver_personnel_readiness`:
- Add `PersonnelPresentPct` (calculated percentage)
- Add `PersonnelAbsent` (calculated count)
- Add `ReadinessCategory` (Excellent/Good/Satisfactory/Needs Improvement)

For `silver_equipment_inventory`:
- Add `OperationalPct` (calculated percentage)
- Add `DaysUntilInspection` (date calculation)
- Add `InspectionStatus` (Overdue/Due Soon/Current)

For `silver_training_metrics`:
- Add `CompletionRate` (calculated percentage)
- Add `TrainingEffectiveness` (Highly Effective/Effective/Needs Improvement)

**Gold Layer (Aggregated):**

`gold_unit_readiness_summary`:
- Group by: UnitID, UnitName, Brigade, Division
- Aggregate: AvgReadinessScore, AvgPersonnelPresent, ReportCount
- Classify: OverallReadiness (GREEN/AMBER/RED status)

#### 4. **Semantic Model**
- ✅ Create semantic model named `ArmyReadinessSemanticModel`
- ✅ Include 4 tables: Gold (main), Silver Personnel, Silver Equipment, Silver Training
- ✅ Define relationships:
  - Gold → Personnel (One-to-Many on UnitID)
  - Gold → Equipment (One-to-Many on UnitID)
  - Gold → Training (One-to-Many on UnitID)
- ✅ Create minimum 10 DAX measures (see report requirements below)

#### 5. **Power BI Dashboard**
- ✅ Single-page executive dashboard
- ✅ Professional military theme (dark blue/green color scheme)
- ✅ Title: "ARMY UNIT READINESS DASHBOARD"
- ✅ Interactive filters and cross-filtering enabled

---

## 📊 Final Report Requirements

### **Dashboard Title Section**
- Large, bold title: "ARMY UNIT READINESS DASHBOARD"
- Professional formatting (dark blue background, white text)

### **Key Performance Indicators (KPI Cards)**

Must include at minimum 3 KPI cards showing:

1. **Total Units** - Count of all units being monitored
2. **Readiness Percentage** - Overall percentage of units in GREEN status
3. **Units at Risk** - Count of units in RED status

### **Required Visualizations**

The dashboard must contain at minimum **5 key visualizations**:

#### **Visualization 1: Readiness Status by Division**
- **Type**: Stacked Bar Chart
- **Legend** (add FIRST): OverallReadiness (GREEN/AMBER/RED)
- **Y-axis**: Division
- **X-axis**: UnitID (Count Distinct)
- **Color**: GREEN = Green, AMBER = Orange, RED = Red
- **Purpose**: Show readiness status distribution across divisions

#### **Visualization 2: Readiness Trend or Distribution**
- **Type**: Donut Chart or Pie Chart
- **Legend**: OverallReadiness status
- **Values**: Count of units (Units GREEN, Units AMBER, Units RED)
- **Purpose**: At-a-glance status distribution

#### **Visualization 3: Division/Brigade Breakdown**
- **Type**: Matrix or Table
- **Rows**: Division, Brigade, Unit Name
- **Values**: AvgReadinessScore, AvgPersonnelPresent
- **Purpose**: Hierarchical view for command structure

#### **Visualization 4: Equipment Readiness**
- **Type**: Clustered Bar Chart or Gauge
- **Data**: From silver_equipment_inventory table
- **Values**: Equipment Readiness % or Operational vs. Total Equipment
- **Purpose**: Show equipment operational status

#### **Visualization 5: Training Effectiveness**
- **Type**: Column Chart or Table
- **Data**: From silver_training_metrics table
- **Values**: Training Completion Rate, Pass Rate, or Training Effectiveness categories
- **Purpose**: Monitor training program success

### **Required DAX Measures**

Your semantic model must include at minimum these 10 measures:

**Unit Readiness Measures (on gold_unit_readiness_summary):**
1. `Total Units` - Count of distinct units
2. `Units GREEN` - Count of units with GREEN status
3. `Units AMBER` - Count of units with AMBER status
4. `Units RED` - Count of units with RED status
5. `Readiness Percentage` - Percentage of GREEN units

**Equipment Measures (on silver_equipment_inventory):**
6. `Total Equipment` - Sum of equipment quantities
7. `Operational Equipment` - Sum of operational equipment
8. `Equipment Readiness %` - Percentage of operational equipment

**Training Measures (on silver_training_metrics):**
9. `Avg Training Pass Rate` - Average of PassRate column
10. `Avg Completion Rate` - Average of CompletionRate column

**Optional Advanced Measures:**
- Personnel present percentages
- Combined readiness scores
- Trend calculations (period-over-period)

### **Interactivity Requirements**

- ✅ Slicers for Division and Brigade filtering
- ✅ Cross-filtering between visuals (clicking one visual filters others)
- ✅ Tooltips showing additional context
- ✅ Drill-down capability on hierarchical data

### **Formatting Standards**

- **Color Scheme**: 
  - GREEN status: #107C10 (dark green)
  - AMBER status: #FF8C00 (dark orange)
  - RED status: #D13438 (dark red)
  - Background: Light gray or white
  - Headers: Dark blue (#003366)

- **Fonts**: 
  - Headers: Segoe UI Bold, 14-16pt
  - Body text: Segoe UI, 10-12pt
  - KPIs: 36-48pt

- **Layout**:
  - Title at top spanning full width
  - KPI cards prominently displayed (top or left side)
  - Visuals arranged in logical flow
  - Adequate white space between elements

---

## 🎓 Learning Outcomes

Upon successful completion, you will have demonstrated ability to:

### **Data Engineering Skills**
- ✅ Create and configure Fabric Lakehouse
- ✅ Build Data Pipelines for orchestration
- ✅ Design Dataflow Gen2 with Power Query
- ✅ Implement medallion architecture (Bronze/Silver/Gold)
- ✅ Create calculated columns and transformations
- ✅ Aggregate data for reporting layer

### **Data Modeling Skills**
- ✅ Design star schema with fact and dimension tables
- ✅ Define proper relationships (one-to-many)
- ✅ Avoid many-to-many relationship complexity
- ✅ Write DAX measures and calculations
- ✅ Create semantic models for business users

### **Data Visualization Skills**
- ✅ Build executive dashboards in Power BI
- ✅ Select appropriate chart types for data
- ✅ Apply conditional formatting
- ✅ Enable interactivity and cross-filtering
- ✅ Design for military/operational audience

### **Microsoft Fabric Platform Skills**
- ✅ Navigate Fabric workspace and experiences
- ✅ Understand Lakehouse vs. Warehouse vs. SQL Endpoint
- ✅ Use Data Pipelines for orchestration
- ✅ Leverage Dataflow Gen2 for transformations
- ✅ Publish and share Power BI reports

---

## 📈 Expected Insights from Final Dashboard

When complete, your dashboard should enable commanders to answer:

### **Readiness Questions**
- How many units are currently GREEN/AMBER/RED?
- Which units need immediate attention?
- What is our overall readiness percentage?
- Which brigade or division is performing best?

### **Personnel Questions**
- What percentage of personnel are present across units?
- Which units have the highest absent rates?
- How does personnel readiness correlate with overall readiness?

### **Equipment Questions**
- What percentage of equipment is operationally ready?
- How many equipment items need inspection?
- Which units have equipment readiness issues?

### **Training Questions**
- What is the average training completion rate?
- Which training events are most effective?
- Are there training gaps affecting readiness?

### **Cross-Domain Insights**
- Is there correlation between training and readiness?
- Do units with better equipment have higher readiness?
- Which domain (personnel/equipment/training) drives overall readiness?

---

## ⏱️ Time Allocation

| Phase | Activity | Time | Deliverable |
|-------|----------|------|-------------|
| 1 | Environment Setup | 10 min | Workspace + Lakehouse created |
| 2 | Data Pipeline Creation | 15 min | Pipeline created, GitHub URLs ready |
| 3 | Dataflow Gen2 Transformations | 45 min | Bronze/Silver/Gold tables populated |
| 4 | Semantic Model Creation | 15 min | Model with relationships + DAX measures |
| 5 | Power BI Dashboard | 20 min | Interactive dashboard with 5+ visuals |
| 6 | Automation (Optional) | 10 min | Scheduled refresh configured |
| **Total** | **Core Lab** | **105 min** | **Complete solution** |

---

## ✅ Final Checklist

Before submitting/presenting your solution, verify:

### **Data Platform**
- [ ] Lakehouse created and accessible
- [ ] 3 CSV files accessed via GitHub Web connector
- [ ] 3 Bronze tables exist with raw data
- [ ] 3 Silver tables exist with transformations
- [ ] 1 Gold table exists with unit-level aggregations

### **Data Pipeline**
- [ ] Pipeline created and successfully executed
- [ ] Dataflow Gen2 published and functional
- [ ] All 7 queries (3 Bronze, 3 Silver, 1 Gold) working
- [ ] Pipeline can be run on-demand

### **Semantic Model**
- [ ] Model includes 4 tables (Gold + 3 Silver: Personnel, Equipment, Training)
- [ ] 3 relationships defined (all one-to-many from Gold table)
- [ ] Minimum 10 DAX measures created
- [ ] Measures calculate correctly

### **Power BI Dashboard**
- [ ] Report titled "ARMY UNIT READINESS DASHBOARD"
- [ ] 3 KPI cards displaying key metrics
- [ ] 5 visualizations showing different perspectives
- [ ] Slicers for Division and Brigade
- [ ] Cross-filtering enabled
- [ ] Professional color scheme applied
- [ ] Report published to workspace

### **Functionality**
- [ ] Dashboard filters work correctly
- [ ] Visuals update based on selections
- [ ] Data refreshes successfully
- [ ] All calculations produce accurate results

---

## 🎖️ Bonus Challenges (Optional)

For advanced students who complete early:

1. **Add Row-Level Security (RLS)**
   - Restrict data visibility by Division
   - Test with different user roles

2. **Create Drill-Through Pages**
   - Unit detail page showing all metrics for one unit
   - Equipment detail page listing all equipment items

3. **Add Trend Analysis**
   - Use the 3-month date range in the data
   - Show readiness trending up/down over time
   - Create month-over-month comparisons

4. **Build Mobile Layout**
   - Create mobile-optimized view of dashboard
   - Ensure KPIs are prominent on small screens

5. **Implement Alerts**
   - Configure data-driven alerts for RED status units
   - Send notifications when readiness drops

6. **Add Predictive Analytics**
   - Use AI visuals to forecast readiness trends
   - Identify units at risk of declining readiness

---

## 📚 Reference Data

### **Data Sources Provided**

**personnel_readiness.csv** (30 records)
- 10 units across 2 divisions
- 3 months of data (January - March 2025)
- Personnel counts, readiness scores, status

**equipment_inventory.csv** (30 records)
- Equipment types: Vehicles, Weapons, Communications
- Quantity, operational quantity, condition status
- Inspection dates and maintenance records

**training_metrics.csv** (30 records)
- Training types: Combat, Weapons, PT, Medical, etc.
- Completion rates, pass rates, effectiveness ratings
- Scheduled vs. completed participants

### **Expected Table Counts**

After successful completion:
- Bronze tables: 30 rows each (3 tables × 30 rows = 90 rows total)
- Silver tables: 30 rows each (3 tables × 30 rows = 90 rows total)
- Gold table: 10 rows (1 row per unit)

---

## 🏆 Success Indicators

Your solution is successful when:

1. **Commanders can see at a glance** which units need attention (RED status)
2. **Data is trustworthy** - transformations are accurate and calculations correct
3. **Dashboard is intuitive** - requires minimal training to use
4. **Solution is automated** - can refresh daily/weekly without manual intervention
5. **Performance is good** - visuals load quickly, interactions are responsive

---

## 🎯 Final Deliverables

Submit/present the following:

1. ✅ **Live Power BI Dashboard** - Accessible via Fabric workspace
2. ✅ **Screenshot of Data Model** - Showing tables and relationships
3. ✅ **List of DAX Measures** - With formulas documented
4. ✅ **Dataflow Gen2 Queries** - Screenshot of query list
5. ✅ **Brief Summary** - 2-3 paragraphs describing your solution

---

## 📞 Support Resources

If you encounter issues:

1. **Review Lab Guide** - Step-by-step instructions in `Lab_Guide_Army_Readiness_Analytics.md`
2. **Check Data** - Verify CSV files loaded correctly
3. **Validate Transformations** - Preview data in Dataflow Gen2
4. **Test Relationships** - Ensure filters flow correctly
5. **Review DAX** - Check for syntax errors in measures

---

**CLASSIFICATION: UNCLASSIFIED // FOR TRAINING USE ONLY**

*All data is fictional and created for educational purposes*

---

**Good luck, and remember: Mission first, soldiers always!** 🎖️
