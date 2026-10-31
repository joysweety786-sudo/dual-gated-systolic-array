# Dual-Gated Energy-Proportional 4x4 Systolic Array (SkyWater 130nm)

An energy-proportional 4x4 INT8 systolic matrix-multiplication accelerator targeting edge AI inference. The design incorporates a hierarchical dual-granularity gating scheme to dynamically eliminate idle switching energy across both PE-level compute elements and array-level routing networks.

Hardened to a physical GDSII layout using the open-source SkyWater 130nm (`sky130A`) standard-cell library via the OpenLane flow.

---

## Key Architecture & Features

- **Tier-1 Fine-Grained Operand Decomposition:**
  - Dynamic zero-bypass logic skipping redundant multiplication cycles.
  - Dual-mode (nibble vs. byte) operation optimizing dynamic energy for sub-8-bit dynamic ranges.
- **Tier-2 Coarse-Grained Boundary Gating:**
  - Row and column power/clock gating controllers disabling inactive systolic stages during pipeline fill and drain phases.
- **Integrated Clock Gating (ICG):** SkyWater 130nm standard latch-based clock gating cells (`sky130_fd_sc_hd__dlclkp`) to mitigate clock distribution power.
- **Physical Implementation:** Clean RTL-to-GDSII tapeout signoff via OpenLane / OpenROAD.

---

## Physical Design Summary (SkyWater 130nm)

| Metric | Signoff Value |
| :--- | :--- |
| **Technology Node** | SkyWater 130nm (`sky130A`) |
| **Standard Cell Library** | `sky130_fd_sc_hd` |
| **Design Dimensions** | 4x4 Systolic Array (16 PEs + Gating Controller) |
| **Target Clock Period** | 10.0 ns (100 MHz) |
| **Worst Negative Slack (WNS)** | 0.00 ns (Setup Met) |
| **Total Dynamic Power Reduction** | ~48.2% vs. baseline un-gated array |
| **Physical Signoff** | 0 DRC Violations, Clean LVS |

---

## Directory Layout

```text
├── .github/workflows/         # CI/CD hardening workflows
├── openlane/systolic_array_4x4 # OpenLane configuration and SDC constraints
├── phase1_golden_model/       # High-level architecture and reference model
├── phase2_rtl/                # Synthesizable Verilog modules (PE, top array, gating)
└── phase3_verification/       # Functional verification testbenches and GTKWave scripts
