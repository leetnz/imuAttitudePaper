# rm -Rf build
# cp -R ../docs/src build
# rpl -v \\\\ \\\\\\\\ build/*.md

mkdir -p src/images
cp -R ../docs/src/images src

pandoc -o imuPaper.pdf \
    ../docs/src/10_Introduction.md \
    ../docs/src/20_SystemOfEquations.md \
    ../docs/src/30_EstimatorDesign.md \
    ../docs/src/31_KFDesign.md \
    ../docs/src/32_Simplification.md \
    ../docs/src/33_TrustFunction.md \
    ../docs/src/34_ComplimentryTrustEstimator.md \
    ../docs/src/50_Simulation.md \
    ../docs/src/99_References.md \
    --pdf-engine-opt=-shell-escape --include-in-header=gif2png.tex
