# AE 520 -- Homework 1

Selected solutions for **Problems 1, 5, 7, 8, and 11**. The document contains solutions only, without the question statements. Problem 11 is the selected advanced problem.

Problem 1 follows the student's supplied handwritten sequence, with work-sign and total/molar/mass-specific notation corrections. Problems 5, 7, 8, and 11 follow the same format: state the conditions, write the governing equation, show substitutions and cancellations, then report the result and a short physical explanation.

## Project files

- `main.tex`: main document for Overleaf; use pdfLaTeX.
- `solutions/problem1.tex`, `problem5.tex`, `problem7.tex`, `problem8.tex`, `problem11.tex`: one editable file per problem.
- `preview/Boyang Chen AE 520 HW1 - Solutions.pdf`: compiled document.
- `matlab/HW1_Problem7.m`, `matlab/HW1_Problem8.m`, and `matlab/HW1_Problem11.m`: separate standalone numerical checks, verified with MATLAB R2024b.
- `preview/workflow-test.pdf`: earlier workflow test, retained for reference; not the current solution.

Exact lecture-note PDF pages and equation numbers are retained in comments next to the corresponding LaTeX derivations. The original handwritten PDF, assignment, course notes, and detailed study solutions remain unchanged outside this repository.

## Compilation and synchronization

The document has been compiled locally with Tectonic 0.17.0 and visually checked. Tectonic is XeTeX-based; the source disables unsupported microtype letterspacing for XeTeX only.

```text
tectonic main.tex
```

In Overleaf, select `main.tex` as the main document. For an existing GitHub-linked project, open **Integrations > GitHub** and pull the new changes. Otherwise, create a project with **New Project > Import from GitHub**. Synchronization requires an eligible plan and is manual. See [Overleaf's GitHub synchronization documentation](https://docs.overleaf.com/integrations-and-add-ons/git-integration-and-github-synchronization/github-synchronization).

## Template

The author field is retained from the supplied `HW template.tex`. Supporting files are unmodified copies from [simurgh9/hw](https://github.com/simurgh9/hw), commit `0ba9476e3d3581fb2e8d37212410b8337eb70749`, which is linked by the [Overleaf Homework Template](https://www.overleaf.com/latex/templates/overleaf-homework-template/tjpxvcfnrqpd). Their original copyright notices and GPL v3-or-later license are retained in `COPYING`.

## AI assistance

ChatGPT assisted with LaTeX preparation and checking for Problem 1 based on the student's handwritten steps, and with drafting and checking Problems 5, 7, 8, and 11. The PDF contains an acknowledgment describing that assistance. This repository does not submit work to Canvas.
