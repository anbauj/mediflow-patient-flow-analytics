# 🏥 MediFlow: Hospital Outpatient Patient-Flow Tracker & Analytics Dashboard

[![Python](https://img.shields.io/badge/Python-3.11%20%7C%203.13-blue.svg)](https://www.python.org/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.40+-FF4B4B.svg)](https://streamlit.io/)
[![Plotly](https://img.shields.io/badge/Plotly-5.18+-3F4F75.svg)](https://plotly.com/)
[![SQLite](https://img.shields.io/badge/SQLite-Indexed-003B57.svg)](https://www.sqlite.org/)
[![Tests](https://img.shields.io/badge/pytest-Passing-brightgreen.svg)](https://pytest.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **⚠️ PRIVACY NOTICE & SYNTHETIC DATA DISCLAIMER**:  
> **MediFlow uses 100% synthetic, procedurally-generated operational healthcare data.**  
> Absolutely **NO real patient data or Protected Health Information (PHI)** is collected, stored, or processed anywhere within this project.

---

## 📖 1. Project Overview & Context

**MediFlow** is a comprehensive, clinical-grade Outpatient Patient-Flow Tracker and Operations Analytics Dashboard designed to monitor appointment schedules, eliminate waiting room bottlenecks, anticipate no-shows, and provide automated rule-based capacity recommendations for healthcare leadership.

Built as an engineering portfolio piece demonstrating **Agile/Scrum delivery**, **data engineering**, and **clinical operations analysis**, MediFlow translates raw appointment timestamps into actionable decisions for **Hospital Administrators**, **Department Heads**, and **Front-Desk Receptionists**.

---

## 🎯 2. Problem Statement

Outpatient hospital departments operate under high stochastic demand:
1. **Unpredictable Waiting Room Surges**: Peak arrival hours (10:00 AM – 1:00 PM) and Monday volume spikes create cascading patient delays, driving patient dissatisfaction and clinician stress.
2. **Costly No-Shows**: High no-show rates on pre-booked appointments (reaching 28–32% in late afternoons) leave expensive clinical staff idle.
3. **Information Asymmetry at Front Desk**: Reception staff lack real-time visibility into active doctor consultation states and reliable wait forecasts for arriving walk-in patients.
4. **Reactive Decision-Making**: Hospital administrators often rely on delayed retrospective weekly audits rather than real-time bottleneck detection and prescriptive staffing interventions.

**MediFlow** bridges these operational gaps with real-time tracking, 2D heatmaps, a 15-minute stepping live queue simulator, and rule-based prescriptive recommendations.

---

## 🏗️ 3. System Architecture

```mermaid
flowchart TD
    subgraph Data_Layer ["Data & Storage Layer"]
        GEN["Synthetic Data Generator<br/>(src/generate_data.py)<br/>• Seeded (seed=42)<br/>• 6 Months, ~15k Visits"] -->|Populates| SQL[("SQLite Database<br/>(data/mediflow.db)<br/>• patients, doctors, appointments<br/>• B-tree Indexes")]
    end

    subgraph Analytics_Layer ["Analytics & Logic Layer"]
        SQL -->|Repository Queries| DB_MOD["Database Access Layer<br/>(src/database.py)"]
        DB_MOD --> METRICS["Metrics & Analytics Engine<br/>(src/metrics.py)<br/>• Executive KPIs<br/>• Heatmaps & Bottlenecks<br/>• Slot Risk Scoring<br/>• Prescriptive Rules"]
    end

    subgraph Presentation_Layer ["Streamlit UI (Dark Clinical Theme)"]
        METRICS -->|Cached (@st.cache_data)| MAIN["Streamlit App Controller<br/>(app/main.py)"]
        MAIN --> V1["📊 Executive Overview<br/>(app/views/overview.py)"]
        MAIN --> V2["⏱️ Wait-Time Analysis<br/>(app/views/wait_time.py)"]
        MAIN --> V3["🚫 No-Show Analysis<br/>(app/views/no_show.py)"]
        MAIN --> V4["🚦 Live Queue Simulator<br/>(app/views/queue_sim.py)"]
        MAIN --> V5["💡 Recommendations<br/>(app/views/recommendations.py)"]
        MAIN --> EXP["📥 Filtered CSV Export"]
    end
```

---

## 🚀 4. How to Run

### Prerequisites
- Python 3.11 or higher
- Git

### Installation & Launch in 3 Simple Steps

```bash
# 1. Clone repository
git clone https://github.com/your-username/mediflow.git
cd mediflow

# 2. Install dependencies
pip install -r requirements.txt

# 3. Launch MediFlow Dashboard (one-command run)
streamlit run app/main.py
```

The web dashboard will automatically open in your default browser at `http://localhost:8501`.

### Running Unit Tests
MediFlow comes with a comprehensive `pytest` suite verifying data generation integrity, timestamp chronological order, wait time math, and rule recommendation triggers:

```bash
python -m pytest
```

---

## 🗄️ 5. Relational Data Dictionary

The synthetic database consists of three normalized tables stored in `data/mediflow.db`:

### `patients`
| Field | Type | Description |
| :--- | :--- | :--- |
| `patient_id` | `TEXT (PK)` | Unique patient identifier (e.g., `PAT-10042`) |
| `age_group` | `TEXT` | Cohort: `Pediatric (0-17)`, `Young Adult (18-35)`, `Adult (36-64)`, `Senior (65+)` |
| `gender` | `TEXT` | Demographic gender: `Female`, `Male`, `Non-Binary` |
| `area` | `TEXT` | Geographic residential catchment zone |

### `doctors`
| Field | Type | Description |
| :--- | :--- | :--- |
| `doctor_id` | `TEXT (PK)` | Unique physician identifier (e.g., `DOC-101`) |
| `name` | `TEXT` | Clinician full name (25 doctors total) |
| `department` | `TEXT` | Specialty: `Cardiology`, `Orthopedics`, `Pediatrics`, `Radiology`, `General Medicine`, `Dermatology` |
| `shift` | `TEXT` | Operational clinic shift: `Morning` (08:00–13:00) or `Afternoon` (13:00–18:00) |

### `appointments`
| Field | Type | Description |
| :--- | :--- | :--- |
| `appointment_id` | `TEXT (PK)` | Unique appointment identifier (e.g., `APT-001234`) |
| `patient_id` | `TEXT (FK)` | Reference to `patients.patient_id` |
| `doctor_id` | `TEXT (FK)` | Reference to `doctors.doctor_id` |
| `department` | `TEXT` | Clinical department |
| `scheduled_time` | `TEXT` | ISO-8601 scheduled visit timestamp |
| `check_in_time` | `TEXT` | Arrival check-in timestamp (`NULL` if no-show) |
| `consult_start_time` | `TEXT` | Clinician exam room entry timestamp |
| `consult_end_time` | `TEXT` | Clinician exam room completion timestamp |
| `status` | `TEXT` | Outcome: `Completed`, `No-Show`, `Cancelled` |
| `booking_type` | `TEXT` | Origin: `Pre-booked` (82%) or `Walk-in` (18%) |
| `wait_time_minutes` | `FLOAT (Derived)` | Latency: `consult_start_time - check_in_time` |
| `consult_duration_minutes`| `FLOAT (Derived)` | Latency: `consult_end_time - consult_start_time` |

---

## 📊 6. Key Findings from the Synthetic Hospital Data

1. **Monday Volume Surge & Peak-Hour Latency**:
   - Mondays experience a **+35% surge** in outpatient arrivals compared to mid-week days.
   - Wait times escalate sharply during **10:00 AM – 1:00 PM**, peaking at **38–46 minutes** in Cardiology and Orthopedics due to high consultation length variance.
2. **Pre-Booked vs. Walk-In No-Show Dynamics**:
   - Pre-booked appointments scheduled on Monday evenings show a **28.4% no-show rate**, compared to a hospital-wide baseline of **13.0%**.
   - Walk-in patients exhibit a near-zero no-show rate (< 2%), demonstrating that evening slots should dynamically shift to rapid-triage walk-in allocation.
3. **Clinician Pacing Discrepancies**:
   - Cardiology average consults span **24.1 ± 5.4 min**, whereas Dermatology consultations average **12.1 ± 2.6 min**. Failing to adjust slot intervals by department creates artificial waiting room delays.

---

## 🖼️ 7. Screenshots & Interface Preview

````carousel
```
+------------------------------------------------------------------------------------------------------+
| 🏥 MediFlow | Outpatient Flow Analytics                                    🔍 Filtered: Cardiology   |
+------------------------------------------------------------------------------------------------------+
| [ 📅 Appointments: 15,261 ] [ ⏱️ Avg Wait: 21.4 min ] [ 🚫 No-Show: 13.0% ] [ 🩺 Consult: 17.2m ]   |
+------------------------------------------------------------------------------------------------------+
| 🏥 Appointment Outcomes by Department                 📈 Daily Outpatient Volume Trend (7-Day Avg)   |
| [======================= Completed (82%) ============] [~~~~~~/\~~~~~/\~~~~~~/\~~~~~~~~~~~~~~~~~~~~] |
| [=== No-Show (13%) ===] [= Cancelled (5%) =]                                                         |
+------------------------------------------------------------------------------------------------------+
```
<!-- slide -->
```
+------------------------------------------------------------------------------------------------------+
| ⏱️ Wait-Time Heatmap: Day of Week vs. Hour of Day                                                    |
+------------------------------------------------------------------------------------------------------+
| Hour:    08:00  09:00  10:00  11:00  12:00  13:00  14:00  15:00  16:00  17:00                        |
| Monday   14.2m  18.5m  38.1m  44.6m  41.2m  26.4m  21.0m  19.5m  16.2m  12.0m  <- (🚨 Peak Congest) |
| Tuesday  11.0m  14.2m  24.5m  28.1m  25.0m  18.2m  16.0m  14.1m  12.5m  10.2m                        |
| Saturday  8.5m  10.1m  14.2m  16.0m  15.1m  12.0m  10.5m   9.0m   8.2m   7.5m                        |
+------------------------------------------------------------------------------------------------------+
```
<!-- slide -->
```
+------------------------------------------------------------------------------------------------------+
| 🚦 Live Outpatient Queue Simulation ("Today" View)          Simulated Clock: ⏰ 11:15 AM (Monday)    |
| [⏩ Advance 15 Min]   [⚡ Jump to Peak]   [🔄 Reset Day]                                              |
+------------------------------------------------------------------------------------------------------+
| 🪑 Waiting Room Queue (Cardiology: 7 Waiting)         🩺 Clinician Room Status                       |
| • PAT-10492 | Adult (36-64) | Elapsed: 26m             • Dr. Sarah Jenkins: 🟢 In Consult (~8m left)  |
| • PAT-10508 | Senior (65+)  | Elapsed: 18m             • Dr. Anita Roy:     🟢 In Consult (~14m left) |
| • PAT-10521 | Walk-in       | Elapsed: 5m              • Dr. Elena Rostova: ⚪ Available / Idle       |
+------------------------------------------------------------------------------------------------------+
```
````

---

## 🏃 8. How Scrum Was Applied

This project strictly followed the Agile Scrum framework across two 1-week timeboxed sprints:

### Scrum Artifacts & Documentation (in `/docs`)
- **[Product Vision (`docs/product_vision.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/product_vision.md)**: Product goals, clinical personas, and measurable success metrics.
- **[Product Backlog (`docs/product_backlog.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/product_backlog.md)**: 18 user stories formatted as `As a <role>, I want <goal> so that <benefit>`, estimated via Fibonacci story points and prioritized using MoSCoW.
- **[Sprint 1 Plan (`docs/sprint_1.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/sprint_1.md)**: Velocity of 27 pts; delivered synthetic generator, database, and Executive Overview.
- **[Sprint 2 Plan (`docs/sprint_2.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/sprint_2.md)**: Velocity of 39 pts; delivered wait heatmaps, no-show risk model, live queue simulator, and rule recommendations.
- **[Burndown Charts (`docs/plot_burndown.py`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/plot_burndown.py)**: Tracks ideal vs actual daily story point burndown across both sprints.
- **[Sprint Reviews (`docs/sprint_review.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/sprint_review.md)**: Formal demonstration logs and simulated stakeholder feedback.
- **[Sprint Retrospective (`docs/retrospective.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/retrospective.md)**: Wins, challenges, and actionable **Start / Stop / Continue** operational retro items.
- **[Kanban Board (`docs/board.md`)](file:///C:/Users/admin/.gemini/antigravity/scratch/mediflow/docs/board.md)**: Scrumban board enforcing Work-In-Progress (WIP) limits.

---

## 📁 9. Repository Structure

```
mediflow/
├── README.md                   # Main portfolio documentation & overview
├── requirements.txt            # Python dependencies (Streamlit, Plotly, Pandas, etc.)
├── pytest.ini                  # Pytest configuration
├── data/
│   └── mediflow.db             # Seeded SQLite database (15,261 appointments)
├── src/
│   ├── __init__.py
│   ├── generate_data.py        # Seeded synthetic generator (~15,000 appointments)
│   ├── database.py             # SQLite persistence, indexing & query repository
│   ├── metrics.py              # Statistical aggregations, KPIs & recommendation engine
│   └── seed.py                 # Quick-seeding utility script
├── app/
│   ├── __init__.py
│   ├── main.py                 # Streamlit entry point & navigation controller
│   ├── styles.css              # Dark clinical glassmorphism design system
│   ├── components/
│   │   ├── __init__.py
│   │   ├── kpi_cards.py        # Executive KPI card components with status badges
│   │   └── filters.py          # Sidebar global filter controls & state manager
│   └── views/
│       ├── __init__.py
│       ├── overview.py         # Executive overview dashboard
│       ├── wait_time.py        # Wait-time heatmap & bottleneck analyzer
│       ├── no_show.py          # No-show multi-factor analysis & slot risk scoring
│       ├── queue_sim.py        # 15-minute stepping live outpatient queue simulator
│       └── recommendations.py  # Prescriptive rule-based clinical insights
├── tests/
│   ├── test_data_generation.py # Generator schema & timestamp validation tests
│   ├── test_metrics.py         # KPI, heatmap & bottleneck math unit tests
│   └── test_app_integration.py # Streamlit filter and data integration tests
└── docs/
    ├── product_vision.md       # Product vision & stakeholder personas
    ├── product_backlog.md      # 18 prioritized user stories (MoSCoW & Fibonacci)
    ├── sprint_1.md             # Sprint 1 plan, task breakdown & standup logs
    ├── sprint_2.md             # Sprint 2 plan, task breakdown & standup logs
    ├── board.md                # Kanban board view with WIP limits
    ├── burndown_data.csv       # Daily burndown tracking data
    ├── plot_burndown.py        # Automated burndown visualization script
    ├── burndown_charts.html    # Generated interactive Plotly burndown report
    ├── sprint_review.md        # Demo notes & stakeholder feedback
    └── retrospective.md        # Retrospective analysis (Start / Stop / Continue)
```

---

## 📄 License
This project is open-source under the MIT License.
