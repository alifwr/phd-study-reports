# PhD Study Report — LaTeX Template

Each chapter lives in its own directory under `chapters/`, with a local
`figures/` folder for that chapter's images.

## Layout

```
main.tex                     root document — \include order lives here
latexmkrc                    build config (pdflatex + biber, out -> build/)
preamble/
  packages.tex               all \usepackage lines
  style.tex                  layout, headers, listings, toc helper
  macros.tex                 metadata + custom commands (edit title here)
frontmatter/
  titlepage.tex
  abstract.tex
chapters/
  01-introduction/
    main.tex                 the chapter source
    figures/                 chapter-local images
  02-literature-review/
  03-methodology/
  04-results/
  05-conclusion/
appendices/
  A-extra/
    main.tex
    figures/
references/
  references.bib             bibliography database
```

## Build

```bash
latexmk -pdf main.tex        # output in build/
latexmk -c                   # clean aux files
```

Or manually:

```bash
pdflatex main && biber main && pdflatex main && pdflatex main
```

## Add a chapter

1. Create `chapters/06-name/main.tex` with a `\chapter{...}` and a
   `figures/` subfolder.
2. Add `\include{chapters/06-name/main}` in `main.tex`.
3. Add the figures path to `\graphicspath` in `preamble/style.tex`.

## Edit metadata

Title, author, supervisor, degree: `preamble/macros.tex`.
