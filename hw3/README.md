# AE 520 -- Homework 3

Complete solutions to Problems 1-4. The presentation follows the equation-first sequence in the earlier homework and handwritten midterm: state the applicable model, write the governing relation, show the key substitutions or cancellations, and box the requested result. Short explanations identify physical assumptions, admissible Mach-number branches, and choking conditions.

The main course material is **Lectures 9-13**: normal shocks, Rayleigh flow, Fanno flow, nozzle flow, and inlet starting. Thermodynamic and stagnation-state relations are used as prerequisites. Exact lecture-note PDF-page and equation references are retained in comments beside the LaTeX calculations. The separate guided solution remains in the local course folder.

## Files

- `hw3.tex`: homework document using the existing template.
- `solutions/problem1.tex` through `problem4.tex`: one editable file per problem.
- `matlab/hw3_problem1.m` through `hw3_problem4.m`: standalone numerical calculations.
- `python/verify_hw3.py`: independently executed calculations and conservation checks using Python's standard library.
- `python/make_hs_figure.py`: the figure generator used for this version; requires ReportLab and Poppler's `pdftoppm`.
- `figures/HW3_Problem1_hs.png`: Mollier diagram for Problem 1(e).
- `figures/HW3_Problem1_hs.pdf`: vector version of the same figure.
- `preview/Boyang_Chen_AE520_HW3.pdf`: submission PDF.
- `node/render_submission.cjs`: reproducible renderer used for this PDF.

## Modeling details

Air is a calorically perfect gas with constant heat capacities, `gamma = 1.4`, `R = 287 J/(kg K)`, and `cp = 1004.5 J/(kg K)`. Pressures and temperatures are absolute. Heat addition is mass-specific and positive into the gas.

In Problem 4, the original sentence connecting the diffuser and second throat is incomplete. The diagram identifies `M = 0.40` in the diffuser and `M = 0.80` at the second throat. The short constant-area heating region is taken to have the second-throat area. The pre-heating Mach number is therefore initially 0.80. The first physical throat is supersonic and is not an upstream sonic reference area.

## Compilation

The repository-root `main.tex` imports `hw3/hw3.tex`. Keep `main.tex` selected as the Overleaf main document and recompile after pulling the GitHub changes. The existing XeTeX compatibility setting disables unsupported microtype tracking; pdfLaTeX remains supported by the template.

For local compilation from this folder:

```text
tectonic hw3.tex
```

Run each MATLAB script separately. Problem 1 recreates its figure; the scripts print intermediate values, selected roots, and numerical checks.

The independent calculations and the figure can also be reproduced from this folder:

```text
python python/verify_hw3.py
python python/make_hs_figure.py
```

## Numerical verification

On November 13, 2026, the standalone Python checks passed for all four problems, including mass, momentum, and energy balances, physical branches, and independent shock/nozzle/heating calculations. The executed root solver uses bisection with interval tolerance `1e-13`. The MATLAB scripts provide equivalent calculations using bracketed `fzero` with `TolX = 1e-12`.

All four MATLAB files passed MATLAB R2024b's static analyzer with no diagnostics. They could not be executed in this session because MATLAB's licensing service failed at startup (error 5201); numerical verification was performed with Python. The figure was generated with ReportLab and Poppler and visually inspected.

## PDF generation

The supplied PDF was generated from the current solution files using their literal LaTeX mathematical expressions, rendered by KaTeX and headless Chrome. All 151 mathematical expressions passed rendering checks. The original LaTeX document remains available for Overleaf. A native LaTeX build could not be completed in this session because Tectonic's required resource bundle was unavailable locally and could not be downloaded.

The PDF follows the existing homework format: 11-point serif text, half-inch margins, numbered pages, and a new page for each problem. The renderer preserves the problem order, all 19 outer subparts, the diagram, and the AI-assistance acknowledgment.

## Template

The class and supporting style files are unchanged copies of the template used for HW1 and HW2, originally from [simurgh9/hw](https://github.com/simurgh9/hw), commit `0ba9476e3d3581fb2e8d37212410b8337eb70749`. Original copyright notices and the GPL v3-or-later license are retained in `COPYING`.

## AI assistance

ChatGPT compared the supplied handwritten midterm with the earlier homework, drafted and checked the solutions, and prepared the numerical calculations, MATLAB scripts, and LaTeX document. The PDF includes an acknowledgment of this assistance. This statement does not claim that the student independently derived or reviewed every step.
