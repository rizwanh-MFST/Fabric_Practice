# Microsoft Fabric Lab - Army Unit Readiness Analytics

## Lab Overview

This comprehensive lab teaches Microsoft Fabric capabilities through a practical Army unit readiness scenario. Students will build an end-to-end analytics solution from data ingestion to Power BI reporting.

**Designed for**: US Army customer using F32 capacity (no M365/SharePoint required)

---

## 📁 Lab Contents

### 1. **Lab_Guide_Army_Readiness_Analytics.md**
   - Complete step-by-step lab instructions (150+ pages)
   - Covers all aspects: Lakehouse, Pipelines, Notebooks, Semantic Models, Power BI
   - Includes 8 parts with exercises and checkpoints
   - Estimated completion time: 3-4 hours

### 2. **Sample Data Files** (`sample-data/`)
   
   **personnel_readiness.csv**
   - Unit personnel status and readiness scores
   - 30 records covering 10 units across 3 months
   - Fields: UnitID, UnitName, Brigade, Division, PersonnelAssigned, PersonnelPresent, ReadinessStatus, ReadinessScore, etc.
   
   **equipment_inventory.csv**
   - Equipment condition and maintenance status
   - 30 records covering vehicles, weapons, and communications equipment
   - Fields: EquipmentID, EquipmentType, EquipmentName, UnitID, Quantity, OperationalQty, ConditionStatus, etc.
   
   **training_metrics.csv**
   - Training completion and performance data
   - 30 records covering various training types
   - Fields: TrainingID, UnitID, TrainingType, TrainingName, ParticipantsCompleted, PassRate, TrainingEffectiveness, etc.

### 3. **Transform_Readiness_Data.ipynb** (`notebooks/`)
   - PySpark notebook for ETL transformations
   - Transforms Bronze → Silver → Gold layers
   - Includes data quality checks and summary reports
   - 20+ code cells with comprehensive transformations

### 4. **Semantic_Model_Queries.sql** (`sql-scripts/`)
   - 60+ SQL queries for data exploration and validation
   - Organized into 9 sections:
     - Data validation & exploration
     - Personnel readiness queries
     - Equipment inventory queries
     - Training metrics queries
     - Gold layer analytics
     - Integrated cross-domain insights
     - Time-based analytics
     - Data quality checks
     - View creation for semantic model
   - Ready to use in SQL Analytics Endpoint

### 5. **Power_BI_Report_Guide.md** (`powerbi-guide/`)
   - Detailed instructions for building 5-page Power BI report
   - 30+ DAX measures with explanations
   - Visual-by-visual configuration guidance
   - Formatting best practices and troubleshooting

---

## 🎯 Learning Objectives

By completing this lab, students will learn to:

1. **Data Engineering**
   - Create and configure Fabric Lakehouse
   - Build Data Pipelines for CSV ingestion
   - Transform data using PySpark notebooks
   - Implement Bronze/Silver/Gold architecture

2. **Data Modeling**
   - Create semantic models with relationships
   - Write DAX measures for KPIs
   - Implement row-level security (RLS)

3. **Data Visualization**
   - Build multi-page Power BI reports
   - Create interactive dashboards
   - Apply conditional formatting
   - Configure drill-through pages

4. **Automation & Governance**
   - Schedule pipeline and notebook execution
   - Set up automated data refreshes
   - Implement data quality checks

---

## 🏗️ Solution Architecture

```
CSV Data Sources
    ↓
Data Pipeline (Copy Data Activities)
    ↓
Lakehouse - Bronze Layer (Raw Delta Tables)
    ↓
PySpark Notebook (ETL Transformations)
    ↓
Lakehouse - Silver Layer (Cleansed + Enriched)
    ↓
Lakehouse - Gold Layer (Aggregated for Reporting)
    ↓
SQL Analytics Endpoint (T-SQL Queries)
    ↓
Semantic Model (Relationships + DAX Measures)
    ↓
Power BI Report (5 Interactive Pages)
```

---

## 📊 Report Pages

1. **Executive Dashboard** - High-level KPIs and status overview
2. **Personnel Readiness Detail** - Manning and readiness analysis
3. **Equipment Readiness Detail** - Equipment condition and maintenance
4. **Training Metrics** - Training completion and effectiveness
5. **Integrated Analytics** - Cross-domain insights and correlations

---

## 🚀 Quick Start Guide

### Prerequisites
- Access to Microsoft Fabric workspace with F32 capacity
- Permissions to create Lakehouses, Pipelines, Notebooks, and Reports
- Basic understanding of SQL and data concepts

### Setup Steps

1. **Create Workspace**
   - Open Microsoft Fabric portal
   - Create new workspace: `Army_Readiness_Analytics`
   - Assign F32 capacity

2. **Upload Sample Data**
   - Copy the 3 CSV files from `sample-data/` folder
   - These will be used as source data

3. **Follow Lab Guide**
   - Open `Lab_Guide_Army_Readiness_Analytics.md`
   - Complete exercises sequentially
   - Use checkpoints to validate progress

4. **Use Supporting Materials**
   - Reference SQL queries in `sql-scripts/` for data exploration
   - Import notebook from `notebooks/` for ETL automation
   - Follow Power BI guide in `powerbi-guide/` for report creation

---

## 📁 File Structure

```
Fabric/
│
├── Lab_Guide_Army_Readiness_Analytics.md      # Main lab instructions
├── README.md                                   # This file
│
├── sample-data/
│   ├── personnel_readiness.csv
│   ├── equipment_inventory.csv
│   └── training_metrics.csv
│
├── notebooks/
│   └── Transform_Readiness_Data.ipynb
│
├── sql-scripts/
│   └── Semantic_Model_Queries.sql
│
└── powerbi-guide/
    └── Power_BI_Report_Guide.md
```

---

## 🎓 Lab Sections Overview

### Part 1: Environment Setup (15 min)
- Create Fabric workspace
- Create Lakehouse

### Part 2: Data Ingestion (30 min)
- Upload CSV files
- Build Data Pipeline with Copy Data activities
- Ingest data into Bronze tables

### Part 3: Data Transformation - Notebooks (45 min)
- Create PySpark notebook
- Transform Bronze → Silver (add calculated columns)
- Create Gold layer (aggregations)
- Run data quality checks

### Part 4: Alternative - Dataflow Gen2 (Optional, 30 min)
- Low-code transformation using Power Query
- Alternative to notebooks for business users

### Part 5: Semantic Model Creation (30 min)
- Open SQL Analytics Endpoint
- Create semantic model
- Define relationships
- Create DAX measures

### Part 6: Power BI Report Building (45 min)
- Build 5 report pages
- Add visuals and interactivity
- Apply formatting and themes
- Create navigation

### Part 7: Automation & Scheduling (15 min)
- Schedule pipeline refresh
- Schedule notebook execution
- Configure semantic model refresh

### Part 8: Advanced Features (Optional, 30 min)
- Implement Row-Level Security
- Create Data Activator alerts
- Add Q&A natural language visual

---

## 💡 Key Features Demonstrated

### Microsoft Fabric Capabilities
- ✅ **Lakehouse** - Unified data platform (Delta Lake)
- ✅ **Data Pipelines** - ETL orchestration
- ✅ **Notebooks** - PySpark transformations
- ✅ **Dataflows Gen2** - Low-code ETL (Power Query)
- ✅ **SQL Analytics Endpoint** - T-SQL querying
- ✅ **Semantic Models** - Business logic layer
- ✅ **Power BI** - Interactive reporting
- ✅ **Data Activator** - Automated alerting
- ✅ **Scheduled Refresh** - Automation

### Best Practices
- Medallion architecture (Bronze/Silver/Gold)
- Separation of concerns (raw vs. curated data)
- Incremental data loading patterns
- Data quality validation
- Row-level security for governance
- Performance optimization techniques

---

## 📈 Sample Metrics & KPIs

### Personnel Metrics
- Total Units
- Readiness Percentage (GREEN/AMBER/RED)
- Average Readiness Score
- Personnel Present %
- Units at Risk

### Equipment Metrics
- Total Equipment Items
- Operational Equipment %
- Equipment in Maintenance
- Overdue Inspections
- Equipment by Type

### Training Metrics
- Total Training Events
- Average Pass Rate
- Completion Rate
- Training Effectiveness
- Participants Trained

### Combined Metrics
- Combined Readiness Score (weighted)
- Cross-domain correlations
- Risk assessment

---

## 🔧 Customization Options

This lab can be easily customized for different scenarios:

1. **Change Data Domain**
   - Replace sample CSVs with other operational data
   - Modify column names and transformations in notebook
   - Update DAX measures for new metrics

2. **Expand Data Sources**
   - Add SQL Database connector instead of CSV
   - Include real-time streaming data
   - Integrate with REST APIs

3. **Add More Complexity**
   - Include more units/divisions
   - Add historical data (years instead of months)
   - Implement slowly changing dimensions

4. **Different Military Branches**
   - Adapt for Navy (ships, squadrons)
   - Adapt for Air Force (aircraft, wings)
   - Multi-service joint operations

---

## 🛠️ Troubleshooting

### Common Issues

**Pipeline fails to run**
- Verify file paths are correct
- Check CSV encoding (should be UTF-8)
- Ensure Lakehouse is created and accessible

**Notebook errors**
- Confirm Lakehouse is attached to notebook
- Check table names match exactly
- Verify Python libraries are available

**Semantic model shows no data**
- Refresh the semantic model manually
- Check relationships are defined correctly
- Verify filters aren't excluding all data

**Report visuals are blank**
- Ensure semantic model refresh completed
- Check slicer/filter settings
- Verify measure syntax is correct

Refer to **Appendix C** in the Lab Guide for detailed troubleshooting steps.

---

## 📚 Additional Resources

### Microsoft Documentation
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
- [Lakehouse Tutorial](https://learn.microsoft.com/fabric/data-engineering/tutorial-lakehouse-introduction)
- [Data Pipelines](https://learn.microsoft.com/fabric/data-factory/data-factory-overview)
- [Power BI Documentation](https://learn.microsoft.com/power-bi/)
- [DAX Reference](https://dax.guide/)

### Learning Paths
- [Get Started with Microsoft Fabric](https://learn.microsoft.com/training/paths/get-started-fabric/)
- [Implement a Lakehouse with Microsoft Fabric](https://learn.microsoft.com/training/paths/implement-lakehouse-microsoft-fabric/)
- [Create reports with Power BI](https://learn.microsoft.com/training/paths/create-reports-power-bi/)

### Community
- [Fabric Community Forum](https://community.fabric.microsoft.com/)
- [Power BI Community](https://community.powerbi.com/)

---

## 🎖️ Lab Scenario Context

This lab uses **unclassified, fictional data** for training purposes. The scenario involves:

- **10 Army units** from 2 divisions (1st Infantry Division, 82nd Airborne Division)
- **4 brigades** with varying readiness levels
- **30 equipment types** including vehicles, weapons, and communications gear
- **30 training events** across multiple training categories
- **3 months** of historical data (January - March 2025)

The data demonstrates typical readiness challenges:
- Units with varying personnel presence rates
- Equipment in different condition states
- Training events with different effectiveness levels
- Green/Amber/Red readiness classifications

---

## ✅ Success Criteria

Upon completion, students should have:

1. ✅ Functional Fabric workspace with all components
2. ✅ Automated data pipeline loading CSV data
3. ✅ Bronze/Silver/Gold Delta tables in Lakehouse
4. ✅ Working PySpark notebook with transformations
5. ✅ Semantic model with relationships and DAX measures
6. ✅ 5-page interactive Power BI report
7. ✅ Scheduled automated refreshes
8. ✅ Understanding of end-to-end Fabric capabilities

---

## 📝 Feedback & Support

This lab was designed specifically for US Army customers learning Microsoft Fabric. 

**For questions or issues**:
- Review troubleshooting section in Lab Guide
- Consult Microsoft Fabric documentation
- Reach out to your Microsoft training contact

---

## 🔐 Classification

**UNCLASSIFIED // FOR TRAINING USE ONLY**

All data in this lab is fictional and unclassified. No real unit information, personnel data, or operational metrics are included.

---

## 📅 Version History

- **Version 1.0** (November 2025) - Initial release
  - Complete lab guide with 8 parts
  - 3 sample CSV datasets
  - PySpark notebook with 20+ cells
  - 60+ SQL queries
  - Comprehensive Power BI guide

---

## 👥 Intended Audience

- **Primary**: US Army data analysts and Power BI users
- **Secondary**: Military personnel learning Microsoft Fabric
- **Tertiary**: DoD/Government data professionals

**Skill Level**: Beginner to Intermediate
- No prior Fabric experience required
- Basic SQL and Excel knowledge helpful
- Power BI familiarity beneficial but not required

---

## ⏱️ Estimated Time

- **Core Lab** (Parts 1-7): 3-4 hours
- **With Optional Sections** (Part 8): 4-5 hours
- **With Report Building**: 5-6 hours total

**Recommended Approach**: 
- Session 1 (2 hours): Parts 1-4 (Setup, Ingestion, Transformation)
- Session 2 (2 hours): Parts 5-7 (Semantic Model, Reporting, Automation)
- Session 3 (1-2 hours): Part 8 + Report refinement (Optional)

---

## 🎯 Next Steps After Lab

1. **Expand the solution**
   - Add more data sources
   - Include predictive analytics (ML models)
   - Build mobile reports

2. **Integrate with Army systems**
   - Connect to real SQL databases
   - Pull from enterprise data warehouses
   - Implement with actual operational data

3. **Scale the architecture**
   - Add more divisions and units
   - Include historical years of data
   - Implement real-time streaming

4. **Enhance governance**
   - Implement comprehensive RLS
   - Add data lineage tracking
   - Create data quality dashboards

---

**END OF README**

*Prepared for US Army Microsoft Fabric Training*  
*Microsoft Fabric F32 Capacity*  
*November 2025*
