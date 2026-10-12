# AE 520 -- Homework 2

Solutions for **Problems 1, 2, and 4**, with a concise attempt at **advanced Problem 6**. Each problem follows the student's equation-first style: assumptions, governing equations, symbolic substitutions, numerical results, and only essential prose. The question statements are omitted.

Problem 6 includes the strong-shock relations, the compression-ratio quadratic, the requested numerical table, and a brief physical explanation. It omits the extended analysis in the separate detailed study solution. This scope does not imply a particular grade.

## Files

- `hw2.tex`: document using the supplied homework template.
- `solutions/problem1.tex`, `problem2.tex`, `problem4.tex`, `problem6.tex`: one editable file per problem.
- `matlab/HW2_Problem1.m`, `HW2_Problem2.m`, `HW2_Problem4.m`, `HW2_Problem6.m`: separate standalone MATLAB scripts.
- `figures/HW2_Problem1_Mass.png`: fixed-control-volume mass plot for Problem 1(d).
- `preview/Boyang Chen AE 520 HW2 - Solutions.pdf`: compiled preview.

Lecture-note page and equation references appear in LaTeX comments beside the relevant calculations. The original homework, course notes, handwritten work, and detailed study solutions remain in the local course folder.

## Compilation

The repository-root `main.tex` currently imports this homework. Keep that file as the Overleaf main document and use pdfLaTeX. The XeTeX compatibility setting only disables unsupported microtype tracking.

For local compilation from this folder:

```text
tectonic hw2.tex
```

Run each MATLAB script separately. Problem 1 recreates its mass plot in `figures/`; the other scripts print numerical results and conservation checks.

## Verification

All four standalone scripts passed in MATLAB R2024b on October 12, 2026. The calculations check mass and momentum conservation, the velocity-gradient decomposition and viscous dissipation, diffuser energy and entropy changes, and the strong-shock quadratic and balances. The six-page PDF was compiled with Tectonic 0.17.0 and visually inspected; the numerical values match the MATLAB output.

## Template

The class and supporting style files are unchanged copies of the template already used for HW1, originally from [simurgh9/hw](https://github.com/simurgh9/hw), commit `0ba9476e3d3581fb2e8d37212410b8337eb70749`. Original copyright notices and the GPL v3-or-later license are retained in `COPYING`.

## AI assistance

ChatGPT drafted and checked these solutions and their LaTeX presentation, following the student's preferred derivation style and questions about the course material. The MATLAB scripts were also prepared and checked with this assistance. This record describes the assistance used; it is not a claim that the student independently derived every step or spent a specified amount of time on the advanced problem. Any course submission should include an accurate acknowledgment consistent with the course instructions.
