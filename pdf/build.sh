rm -Rf src
mkdir -p src/images
cp -R ../docs/src .

# Replace all .gif with .png single frame images for PDF
find src/. -type f -name '*.md' -exec sed -i "s/.gif/.png/g" {} +

pandoc -o imuPaper.pdf \
    00_TitlePage.md \
    src/00_Abstract.md \
    src/10_Introduction.md \
    src/20_SystemOfEquations.md \
    src/30_EstimatorDesign.md \
    src/31_KFDesign.md \
    src/32_Simplification.md \
    src/33_TrustFunction.md \
    src/34_ComplimentryTrustEstimator.md \
    src/50_Simulation.md \
    src/60_Experiment.md \
    src/90_Conclusion.md \
    src/99_References.md \
    --pdf-engine-opt=-shell-escape --include-in-header=gif2png.tex
