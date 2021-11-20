# rm -Rf build
# cp -R ../docs/src build
# rpl -v \\\\ \\\\\\\\ build/*.md

mkdir -p src/images
cp -R ../docs/src/images src

pandoc -o imuPaper.pdf \
    ../docs/src/10_Introduction.md \
    ../docs/src/20_SystemOfEquations.md \
    ../docs/src/21_KFDesign.md \
    ../docs/src/30_Simplification.md \
    ../docs/src/40_TrustFunction.md \
    ../docs/src/99_References.md 
