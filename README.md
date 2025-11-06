# Microsoft Fabric Lab - Army Unit Readiness Analytics

## Lab Overview

This comprehensive lab teaches Microsoft Fabric capabilities through a practical Army unit readiness scenario. Students will build an end-to-end analytics solution from data ingestion to Power BI reporting.

**Designed for**: US Army customer using F32 capacity (no M365/SharePoint required)

---

## 📁 Lab Contents

### 1. **Lab_Challenge_and_Requirements.md**
- Complete challenge overview and success criteria
- Final report requirements and specifications
- Expected deliverables and learning outcomes
- **Read this first** to understand what you need to build

### 2. **Lab_Guide_Army_Readiness_Analytics.md**
- Complete step-by-step lab instructions
- Covers all aspects: Lakehouse, Data Pipelines, Dataflow Gen2, Semantic Models, Power BI
- Includes 6 parts with exercises and checkpoints
- **Estimated completion time: 1-2 hours**

### 3. **Power_BI_Quick_Build_Guide.md**
- Quick visual guide for building the Power BI dashboard
- Step-by-step instructions with exact formatting details
- Layout reference diagram and color specifications
- Troubleshooting tips and pro tips
- **Reference this for Part 5 of the lab**

### 4. **Sample Data Files** (`sample-data/`)
   
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

---

## 🎯 Learning Objectives

By completing this lab, students will learn to:

1. **Data Engineering**
   - Create and configure Fabric Lakehouse
   - Build Data Pipelines for orchestration
   - Transform data using Dataflow Gen2 (Power Query)
   - Implement Bronze/Silver/Gold architecture

2. **Data Modeling**
   - Create semantic models with relationships
   - Write DAX measures for KPIs

3. **Data Visualization**
   - Build Power BI dashboards
   - Create interactive visuals
   - Apply conditional formatting

4. **Automation & Governance** (Optional)
   - Schedule pipeline execution
   - Set up automated data refreshes

---

## 🏗️ Solution Architecture

```
CSV Data Sources
    ↓
Data Pipeline (Orchestration)
    ↓
Dataflow Gen2 (Power Query Transformations)
    ↓
Lakehouse Tables (Bronze/Silver/Gold)
    ↓
Semantic Model (Relationships + DAX Measures)
    ↓
Power BI Report (Interactive Dashboard)
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
- Permissions to create Lakehouses, Pipelines, Dataflows, and Reports
- Basic understanding of SQL and data concepts

### Setup Steps

1. **Create Workspace**
   - Open Microsoft Fabric portal
   - Create new workspace: `Army_Readiness_Analytics`
   - Assign F32 capacity

2. **Access Sample Data**
   - CSV files are hosted on GitHub
   - URLs provided in the lab guide
   - Web connector will load data directly into Dataflow Gen2

3. **Follow Lab Guide**
   - Open `Lab_Guide_Army_Readiness_Analytics.md`
   - Complete exercises sequentially
   - Use checkpoints to validate progress

---

## 📁 File Structure

```
Fabric/
│
├── Lab_Challenge_and_Requirements.md          # Challenge overview & requirements
├── Lab_Guide_Army_Readiness_Analytics.md      # Step-by-step instructions
├── Power_BI_Quick_Build_Guide.md              # Power BI dashboard guide
├── README.md                                   # This file
├── STREAMLINED_VERSION_SUMMARY.md             # Change summary
│
└── sample-data/
    ├── personnel_readiness.csv
    ├── equipment_inventory.csv
    └── training_metrics.csv
```

---

## 🎓 Lab Sections Overview

### Part 1: Environment Setup (10 min)
- Create Fabric workspace
- Create Lakehouse

### Part 2: Data Pipeline Creation (15 min)
- Access CSV files from GitHub
- Create Data Pipeline for orchestration

### Part 3: Data Transformation with Dataflow Gen2 (45 min)
- Create Dataflow Gen2 with Power Query
- Build Bronze layer queries (load CSVs)
- Transform Bronze → Silver (calculated columns)
- Create Gold layer (aggregations)
- Add Dataflow to Pipeline

### Part 4: Semantic Model Creation (15 min)
- Create semantic model from tables
- Define relationships
- Create DAX measures

### Part 5: Build Power BI Report (20 min)
- Add KPI cards
- Create key visuals
- Add interactivity and publish

### Part 6: Automation (Optional, 10 min)
- Schedule Pipeline execution
- Configure semantic model refresh

---

## 💡 Key Features Demonstrated

### Microsoft Fabric Capabilities
- ✅ **Lakehouse** - Unified data platform (Delta Lake)
- ✅ **Data Pipelines** - Orchestration and automation
- ✅ **Dataflow Gen2** - Power Query transformations
- ✅ **Semantic Models** - Business logic layer
- ✅ **Power BI** - Interactive reporting
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
   - Modify column names and transformations in Dataflow Gen2
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

**Dataflow errors**
- Confirm data sources are accessible
- Check Power Query syntax and formulas
- Verify destination Lakehouse tables exist

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
2. ✅ Bronze/Silver/Gold Delta tables in Lakehouse
3. ✅ Working Dataflow Gen2 with Power Query transformations
4. ✅ Semantic model with relationships and DAX measures
5. ✅ Interactive Power BI dashboard
6. ✅ (Optional) Scheduled automated refreshes
7. ✅ Understanding of end-to-end Fabric capabilities

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

- **Version 2.0** (November 2025) - Streamlined Dataflow Gen2 version
  - Complete lab guide with 6 parts (1-2 hours)
  - 3 sample CSV datasets hosted on GitHub
  - Dataflow Gen2 with Power Query transformations
  - Low-code approach using visual interface
  - Comprehensive Power BI quick build guide

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

- **Core Lab** (Parts 1-5): 1.5-2 hours
- **With Optional Automation** (Part 6): 2 hours total

**Recommended Approach**: 
- Complete all parts in one session for best learning experience
- Take breaks between major sections
- Practice with sample data first before using real data

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
