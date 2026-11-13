# Reproducing the supplied PDF

The supplied preview was rendered from the current LaTeX solution files with KaTeX and Chromium. It was **not compiled by a LaTeX engine**. The standard LaTeX project remains available for compilation on Overleaf or a system with its template dependencies installed.

This renderer reads `../hw3.tex` for the author, course, date, title, and AI-assistance statement. It reads `../solutions/problem1.tex` through `problem4.tex`, preserves every mathematical expression verbatim, and converts the supported prose, table, and image markup to HTML. Unsupported commands, missing figures, unexpected problem parts, and mathematical rendering errors stop the build. The layout uses 11-point serif text, half-inch side/top margins, and a new page for each problem after Problem 1.

With Node.js installed, run these commands from this directory:

```text
npm install
npx playwright install chromium
node render_submission.cjs
```

Alternatively, use an installed Chrome/Chromium executable:

```text
node render_submission.cjs --chrome /path/to/chrome
```

The output is `../preview/Boyang_Chen_AE520_HW3.pdf`. Optional `--out FILE`, `--html FILE`, and `--audit FILE` arguments choose the PDF, intermediate HTML, and detailed verification-report paths. The audit records source-file and mathematical-expression SHA-256 hashes, all problem parts, layout checks, and any font resizing. Existing dependency installations can be selected with `--katex-dir DIR` and `--playwright-dir DIR`, where each directory contains that package's `package.json`.

The checked build used KaTeX 0.19.0, Playwright 1.62.1, and installed Google Chrome. All 151 mathematical expressions rendered without errors or font resizing. The PDF contains all four problems and the AI-assistance statement. Its table values, equations, and figure reproduce the accompanying solution content; its pagination can differ from the result of compiling the LaTeX project.
