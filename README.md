# AE 520 Compressible Flow -- LaTeX workflow test

**Test only. This is not a completed homework solution or a submission.**

This project contains a short HW1 Problem 1 excerpt to check the supplied homework template, equation typesetting, compilation, and GitHub transfer. The final version will follow the student's handwritten reasoning and steps.

## Files

- `main.tex`: editable test document; select this as the main document in Overleaf.
- `preview/workflow-test.pdf`: compiled preview of the test document.
- `homework.cls`, `hwcmd.sty`, `hwlst.sty`, `hwsymb.sty`: original template dependencies.
- `COPYING`: upstream template license.

The author field is retained from the supplied local template. The original template and course materials have not been modified.

## Overleaf

Import this GitHub repository into a new Overleaf project and compile `main.tex`. For an existing GitHub-linked project, use its GitHub integration to pull the new commit. GitHub synchronization requires an eligible Overleaf plan and is initiated manually; a GitHub push does not automatically update an open Overleaf project.

The template supports pdfLaTeX. Local verification uses Tectonic 0.17.0 (XeTeX-based):

```text
tectonic main.tex
```

## Template source

The supplied template uses the interface of [Overleaf Homework Template](https://www.overleaf.com/latex/templates/overleaf-homework-template/tjpxvcfnrqpd). Its missing supporting files were obtained, unmodified, from [simurgh9/hw](https://github.com/simurgh9/hw), commit `0ba9476e3d3581fb2e8d37212410b8337eb70749`.

The test document explicitly loads `etoolbox` for the preamble hooks used by the class and disables unsupported microtype letterspacing only under XeTeX/Tectonic. Those third-party files retain their original copyright notices and GNU GPL v3-or-later license; see `COPYING`.

## AI assistance

ChatGPT prepared the test excerpt and LaTeX project. This test must not be represented as a completed or unassisted submission. The acknowledgment in the final document should describe the assistance actually used.


