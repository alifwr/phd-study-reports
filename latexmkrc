# latexmk config — use pdflatex + biber
$pdf_mode = 1;
$bibtex_use = 2;
$biber = 'biber %O %S';
$out_dir = 'build';

# \include writes per-chapter .aux into build/<subdir>/; create those
# subdirs up front so pdflatex can open the aux files.
use File::Path qw(make_path);
foreach my $d (glob('topics/*/*/ appendices/*/')) {
    $d =~ s{/$}{};
    make_path("build/$d");
}
$clean_ext = 'bbl run.xml synctex.gz';
