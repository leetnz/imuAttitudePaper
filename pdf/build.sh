# rm -Rf build
# cp -R ../docs/src build
# rpl -v \\\\ \\\\\\\\ build/*.md

pandoc -o imuPaper.pdf \
    ../docs/src/10_Introduction.md \
    ../docs/src/20_SystemOfEquations.md \
    ../docs/src/21_KFDesign.md \
    ../docs/src/30_Simplification.md \
    ../docs/src/99_References.md 
