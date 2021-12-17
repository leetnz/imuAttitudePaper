# rm -Rf build
# cp -R ../docs/src build
# rpl -v \\\\ \\\\\\\\ build/*.md

mkdir -p src/images
cp -R ../docs/src src

pandoc -o imuPaper.pdf \
    src/10_Introduction.md \
    src/20_SystemOfEquations.md \
    src/30_EstimatorDesign.md \
    src/31_KFDesign.md \
    src/32_Simplification.md \
    src/33_TrustFunction.md \
    src/34_ComplimentryTrustEstimator.md \
    src/50_Simulation.md \
    src/60_Experiment.md \
    src/99_References.md \
    --pdf-engine-opt=-shell-escape --include-in-header=gif2png.tex
