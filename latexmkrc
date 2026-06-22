# latexmk config — use pdflatex + biber
$pdf_mode = 1;
$bibtex_use = 2;
$biber = 'biber %O %S';
$out_dir = 'build';
$clean_ext = 'bbl run.xml synctex.gz';
