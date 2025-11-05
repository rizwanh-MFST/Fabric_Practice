# Power BI Report - Quick Build Guide
## Army Unit Readiness Dashboard

---

## 🎯 Goal

Build a single-page executive dashboard that displays:
- 3 KPI cards (Total Units, Readiness %, Units at Risk)
- 5 key visualizations
- Interactive filters
- Professional military theme

**Time to Complete**: 20 minutes

---

## 📋 Before You Start

✅ **Prerequisites:**
- Semantic model `ArmyReadinessSemanticModel` created
- 3 tables in model: `gold_unit_readiness_summary`, `silver_equipment_inventory`, `silver_training_metrics`
- DAX measures created (minimum 8)
- Relationships defined (Gold → Equipment, Gold → Training)

---

## 🚀 Step-by-Step Build Instructions

### **Step 1: Create New Report (1 minute)**

1. In your Fabric workspace, navigate to `ArmyReadinessSemanticModel`
2. Click **Create report** button at the top
3. Power BI report editor will open
4. **Save** immediately: Name it `Army_Readiness_Dashboard`

---

### **Step 2: Add Report Title (2 minutes)**

1. Click **Insert** tab → **Text box**
2. Type: `ARMY UNIT READINESS DASHBOARD`
3. Format the text box:
   - **Font**: Segoe UI Bold
   - **Size**: 24pt
   - **Alignment**: Center
   - **Font color**: White (#FFFFFF)
   - **Background color**: Dark Blue (#003366)
   - **Border**: None
4. Resize and position at the **top** of the page (spanning full width)
5. Height: ~60 pixels, Width: Full page width

---

### **Step 3: Add Division & Brigade Slicers (3 minutes)**

**Division Slicer:**

1. Click **Insert** → **Slicer**
2. From **Data pane**, drag `gold_unit_readiness_summary[Division]` to the slicer
3. **Format slicer**:
   - Click **Format** pane (paint roller icon)
   - **Slicer settings** → **Style**: Tile
   - **Values** → Font size: 12pt
   - **Background**: Light gray (#F0F0F0)
4. Position: Top-left area below title
5. Size: ~200px wide × 100px tall

**Brigade Slicer:**

6. Repeat steps 1-5 but use `gold_unit_readiness_summary[Brigade]`
7. Position: Next to Division slicer
8. Same size and formatting

---

### **Step 4: Add KPI Cards (5 minutes)**

**Card 1: Total Units**

1. Click **Visualizations** pane → **Card** visual
2. Drag measure `[Total Units]` into the **Fields** well
3. **Format card**:
   - **Callout value** → Font size: 48pt, Color: Dark blue
   - **Category label** → Turn ON, Text: "Total Units", Size: 14pt
   - **Background**: White
   - **Border**: On, Color: Light gray
4. Position: Below slicers, left side
5. Size: ~200px wide × 150px tall

**Card 2: Readiness Percentage**

6. Insert new **Card** visual
7. Drag measure `[Readiness Percentage]` into Fields
8. **Format card**:
   - **Callout value** → Font size: 48pt, Color: Green (#107C10)
   - **Display units**: None
   - **Value decimal places**: 0
   - **Category label**: "Readiness %"
9. Position: Next to Card 1 (center)
10. Same size as Card 1

**Card 3: Units at Risk**

11. Insert new **Card** visual
12. Drag measure `[Units RED]` into Fields
13. **Format card**:
    - **Callout value** → Font size: 48pt, Color: Red (#D13438)
    - **Category label**: "Units at Risk"
14. Position: Next to Card 2 (right side)
15. Same size as previous cards

---

### **Step 5: Add Visualization 1 - Readiness by Unit (3 minutes)**

1. Click **Clustered bar chart** from Visualizations pane
2. **Configure data**:
   - **Y-axis**: `gold_unit_readiness_summary[UnitName]`
   - **X-axis**: `gold_unit_readiness_summary[AvgReadinessScore]`
3. **Format visual**:
   - **Title**: "Unit Readiness Scores"
   - **Data labels**: ON
   - **Y-axis**: Sort by AvgReadinessScore descending
4. **Add conditional formatting**:
   - Click on X-axis value → **Conditional formatting** → **Background color**
   - **Format style**: Rules
   - **Rules**:
     - If value ≥ 95 then Green (#107C10)
     - If value ≥ 90 then Orange (#FF8C00)
     - Else Red (#D13438)
5. Position: Middle-left area below KPI cards
6. Size: ~400px wide × 300px tall

---

### **Step 6: Add Visualization 2 - Status Distribution (2 minutes)**

1. Click **Donut chart** from Visualizations pane
2. **Configure data**:
   - **Legend**: `gold_unit_readiness_summary[OverallReadiness]`
   - **Values**: `[Total Units]`
3. **Format visual**:
   - **Title**: "Readiness Status Distribution"
   - **Legend**: Position = Right
   - **Data labels**: Category, percentage, show
4. **Manual colors**:
   - GREEN = #107C10
   - AMBER = #FF8C00
   - RED = #D13438
5. Position: Top-right area (next to bar chart)
6. Size: ~350px wide × 300px tall

---

### **Step 7: Add Visualization 3 - Unit Details Matrix (2 minutes)**

1. Click **Matrix** visual from Visualizations pane
2. **Configure data**:
   - **Rows**: 
     - `gold_unit_readiness_summary[Division]`
     - `gold_unit_readiness_summary[Brigade]`
     - `gold_unit_readiness_summary[UnitName]`
   - **Values**: 
     - `gold_unit_readiness_summary[AvgReadinessScore]`
     - `gold_unit_readiness_summary[AvgPersonnelPresent]`
     - `gold_unit_readiness_summary[OverallReadiness]`
3. **Format visual**:
   - **Title**: "Unit Hierarchy & Metrics"
   - **Values** → Show on rows: OFF
   - **Row headers** → Stepped layout: ON
   - **Column headers**: Bold, dark blue background
4. **Conditional formatting**:
   - AvgReadinessScore: Data bars, green gradient
   - OverallReadiness: Background color (GREEN/AMBER/RED)
5. Position: Bottom-left area
6. Size: ~600px wide × 250px tall

---

### **Step 8: Add Visualization 4 - Equipment Readiness (2 minutes)**

1. Click **Gauge** visual from Visualizations pane
2. **Configure data**:
   - **Value**: `[Equipment Readiness %]`
   - **Target**: Type `100` (for 100% goal)
3. **Format visual**:
   - **Title**: "Equipment Operational Status"
   - **Gauge axis**: Min = 0, Max = 100
   - **Data labels**: Font size 16pt
   - **Colors**: 
     - 0-75 = Red
     - 75-90 = Orange
     - 90-100 = Green
4. Position: Middle-right area
5. Size: ~300px wide × 250px tall

---

### **Step 9: Add Visualization 5 - Training Metrics (2 minutes)**

1. Click **Clustered column chart** from Visualizations pane
2. **Configure data**:
   - **X-axis**: `silver_training_metrics[TrainingType]`
   - **Y-axis**: `silver_training_metrics[CompletionRate]`
   - **Legend**: `silver_training_metrics[TrainingEffectiveness]`
3. **Format visual**:
   - **Title**: "Training Completion by Type"
   - **Data labels**: ON, show value
   - **Y-axis**: Display units = None, Title = "Completion Rate (%)"
   - **X-axis**: Title = OFF
   - **Legend**: Position = Top
4. Position: Bottom-right area
5. Size: ~400px wide × 250px tall

---

## 🎨 Final Formatting & Polish (3 minutes)

### **Page Background**

1. Click empty area on canvas → **Format page** (paint roller)
2. **Canvas background**:
   - Color: Light gray (#F5F5F5)
   - Transparency: 0%
3. **Page information**:
   - Name: "Executive Dashboard"

### **Align Visuals**

1. Select all visuals (Ctrl+A)
2. **Format** tab → **Align** → **Distribute horizontally**
3. **Format** tab → **Align** → **Align top** (for same row items)

### **Enable Cross-Filtering**

1. Click **Format** → **Edit interactions** (ribbon)
2. For each visual, ensure:
   - Slicers filter all other visuals
   - Clicking on charts cross-filters other visuals
3. Test by clicking on a unit in the bar chart - other visuals should update

### **Add Subtle Borders**

1. For each visual:
   - **Format** pane → **General** → **Effects** → **Background**
   - Background: White
   - Border: On, Color: Light gray (#CCCCCC), Width: 1px

---

## ✅ Testing Your Dashboard (2 minutes)

### **Test Interactivity:**

1. **Click Division slicer** → Select "1st Infantry Division"
   - All visuals should filter to show only that division
   - Unit count should decrease

2. **Click a unit in the bar chart** → Select a specific unit
   - Matrix should highlight that unit
   - Equipment gauge should show that unit's equipment
   - Training chart should filter to that unit's training

3. **Clear filters** → Click slicer "Clear selections"
   - All data should return

### **Validate Data:**

- ✅ Total Units = 10
- ✅ Donut chart shows GREEN/AMBER/RED distribution
- ✅ Matrix shows all divisions and brigades in hierarchy
- ✅ Equipment gauge shows percentage between 0-100
- ✅ Training chart shows different training types

---

## 💾 Save and Publish (1 minute)

1. Click **File** → **Save**
2. Verify name: `Army_Readiness_Dashboard`
3. Click **Share** button in ribbon
4. Click **Publish to this workspace**
5. Wait for publish to complete
6. Click **Open '[report name]' in Power BI** to view published version

---

## 📊 Final Layout Reference

```
┌─────────────────────────────────────────────────────────────────┐
│         ARMY UNIT READINESS DASHBOARD (Dark Blue Header)        │
├──────────────┬──────────────┬───────────────────────────────────┤
│ Division ▼   │ Brigade ▼    │                                   │
│ (Slicer)     │ (Slicer)     │                                   │
├──────────────┴──────────────┴───────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                      │
│  │    10    │  │   85%    │  │    2     │                      │
│  │Total     │  │Readiness │  │Units at  │                      │
│  │Units     │  │    %     │  │  Risk    │                      │
│  └──────────┘  └──────────┘  └──────────┘                      │
├─────────────────────────────────┬───────────────────────────────┤
│                                 │                               │
│   Unit Readiness Scores         │  Readiness Status             │
│   (Horizontal Bar Chart)        │  Distribution                 │
│   - Units listed vertically     │  (Donut Chart)                │
│   - Bars color-coded            │  - GREEN/AMBER/RED            │
│   - Sorted by score             │                               │
│                                 │                               │
├─────────────────────────────────┼───────────────────────────────┤
│                                 │                               │
│  Unit Hierarchy & Metrics       │  Equipment Operational        │
│  (Matrix)                       │  Status (Gauge)               │
│  - Division → Brigade → Unit    │  - Shows % ready              │
│  - Readiness scores             │  - Target = 100%              │
│  - Personnel present %          │                               │
│                                 ├───────────────────────────────┤
│                                 │  Training Completion          │
│                                 │  by Type (Column Chart)       │
│                                 │  - By training type           │
│                                 │  - Grouped by effectiveness   │
└─────────────────────────────────┴───────────────────────────────┘
```

---

## 🎨 Color Reference Guide

### **Status Colors (Use Consistently)**

| Status | Hex Code | RGB | Usage |
|--------|----------|-----|-------|
| **GREEN** | #107C10 | (16, 124, 16) | Excellent readiness (≥95%) |
| **AMBER** | #FF8C00 | (255, 140, 0) | Satisfactory readiness (90-94%) |
| **RED** | #D13438 | (209, 52, 56) | At-risk readiness (<90%) |

### **UI Colors**

| Element | Hex Code | RGB | Usage |
|---------|----------|-----|-------|
| **Title Background** | #003366 | (0, 51, 102) | Header, important text |
| **Text** | #000000 | (0, 0, 0) | Body text, labels |
| **Title Text** | #FFFFFF | (255, 255, 255) | Text on dark backgrounds |
| **Page Background** | #F5F5F5 | (245, 245, 245) | Canvas background |
| **Visual Background** | #FFFFFF | (255, 255, 255) | Card/chart backgrounds |
| **Borders** | #CCCCCC | (204, 204, 204) | Visual borders |

---

## 📝 Common Issues & Quick Fixes

### **Issue: Visuals not filtering each other**

**Fix:**
1. Click **Format** tab → **Edit interactions**
2. Select slicer → Ensure all visuals have filter icon (not "None")
3. Turn off "Edit interactions"

### **Issue: Gauge shows wrong percentage**

**Fix:**
1. Check measure `[Equipment Readiness %]` includes `* 100`
2. In gauge settings, ensure "Display units" = None
3. Verify target value is set to 100

### **Issue: Colors not matching status**

**Fix:**
1. Right-click visual → **Format visual**
2. Go to **Data colors** → Click field → **Conditional formatting**
3. Manually set rules:
   - GREEN: #107C10
   - AMBER: #FF8C00  
   - RED: #D13438

### **Issue: Matrix is too cluttered**

**Fix:**
1. **Format visual** → **Row headers**
2. Turn on **Stepped layout**
3. Enable **+/− icons** for expand/collapse
4. Adjust **Text size** to 10pt

### **Issue: Data labels overlapping**

**Fix:**
1. **Format visual** → **Data labels**
2. Reduce **Text size** to 10pt
3. Set **Position** = Auto or Outside
4. Turn off for less important visuals

---

## 🎯 Pro Tips for Better Dashboards

### **Visual Hierarchy**
1. **Most important at top-left** (natural reading order)
2. **KPIs get largest font** (48pt for numbers)
3. **Use white space** - don't cram visuals together

### **Color Strategy**
1. **Limit to 3-4 colors** (GREEN/AMBER/RED + blue for headers)
2. **Use color meaningfully** - only for status indicators
3. **Gray for neutral elements** (backgrounds, borders)

### **Performance**
1. **Limit visuals to 5-7** per page for best performance
2. **Use measures, not calculated columns** when possible
3. **Filter at source** - use slicers instead of visual-level filters

### **User Experience**
1. **Add tooltips** with additional context
2. **Clear slicer labels** - users should know what they're filtering
3. **Test on mobile** - ensure dashboard works on tablets

---

## ✅ Pre-Publication Checklist

Before sharing your dashboard:

- [ ] All 3 KPI cards display correct values
- [ ] All 5 visualizations load without errors
- [ ] Slicers filter all visuals correctly
- [ ] Cross-filtering works between charts
- [ ] Colors match specification (GREEN/AMBER/RED)
- [ ] Title is properly formatted and centered
- [ ] No overlapping visuals
- [ ] Data labels are readable (not overlapping)
- [ ] Report is saved with correct name
- [ ] Test with both divisions selected individually
- [ ] Clear all filters returns to full dataset
- [ ] Mobile layout (optional) is configured

---

## 🚀 Next Steps After Building

### **Immediate:**
1. **Share with stakeholders** - Use workspace permissions
2. **Create mobile layout** - Format → Mobile layout
3. **Set up scheduled refresh** - Ensure data stays current

### **Enhancements:**
1. **Add drill-through page** - Unit detail view
2. **Create bookmarks** - Save common filter states
3. **Add Q&A visual** - Natural language queries
4. **Enable export to PDF** - For briefings

### **Advanced:**
1. **Row-Level Security** - Restrict by division
2. **Real-time data** - Connect to streaming sources
3. **AI insights** - Add decomposition tree
4. **Alerts** - Notify when units go RED

---

## 📚 Additional Resources

### **Microsoft Learn Modules:**
- [Get started building with Power BI](https://learn.microsoft.com/training/modules/get-started-with-power-bi/)
- [Create visuals in Power BI](https://learn.microsoft.com/training/modules/visuals-power-bi/)
- [Design reports in Power BI](https://learn.microsoft.com/training/modules/power-bi-effective-reports/)

### **Power BI Community:**
- [Power BI Community Forum](https://community.powerbi.com/)
- [Power BI Documentation](https://learn.microsoft.com/power-bi/)
- [DAX Guide](https://dax.guide/)

---

**Time Check:** You should complete this in **20 minutes**. Take your time to ensure quality over speed!

---

**CLASSIFICATION: UNCLASSIFIED // FOR TRAINING USE ONLY**

🎖️ **Good luck building your dashboard!** 🎖️
