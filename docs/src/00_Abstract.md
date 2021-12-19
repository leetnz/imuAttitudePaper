### Abstract

The complimentry trust estimator presented in this whitepaper is useful for:

* Single axis attitude estimation
* Multi-axis attitude estimation where gimbal lock can be tolerated
* Systems with limited computational resources

The estimator requires gyroscopic and accelerometer measurements; these measurements are fused with the following algorithm:

$$
\begin{split}
    \bar{\phi}^{gyro}_k &= \phi^{est}_{k-1} + \frac{\dot{\phi}^{gyro}_k + \dot{\phi}^{gyro}_{k-1}}{2}\Delta t_k \\
    \bar{\phi}^{accel}_{k} &= \tan^{-1}\left(\frac{\ddot{y}^{accel}_K}{\ddot{z}^{accel}_K}\right) \\
    \phi^{est}_{k} &=  \bar{\phi}^{gyro}_k  + f^{trust}(\hat{a}^{accel}_k) \times \left(\bar{\phi}^{accel}_k - \bar{\phi}^{gyro}_k\right)
\end{split}
$$

Where we are estimating the roll $\phi$ which is the angle about the x axis.

A computationally cheap trust function $f^{trust}(\hat{a}_k)$ is defined:

$$
\begin{split}
\left \| \hat{a}^{accel}_k \right \|^2 &= (\ddot{x}^{accel}_k)^2 + (\ddot{y}^{accel}_k)^2 + (\ddot{z}^{accel}_k)^2 \\
f^{trust}(\hat{a}^{accel}_k) &= F^{max} \max\left(0,
1 - \frac{1}{2 K^{tol}}\left( \frac{\left \| \hat{a}^{accel}_k \right \|^2}{g} - 1 \right)\right)
\end{split}
$$

Where:

* $g$ is the gravity constant $9.81m.s^{-1}$
* $F^{max}$ affects the corner frequency of the low-pass/high-pass complimentry filter
  * Make $F^{max}$ small to integrate gyro measurements into the estimator
* $K^{tol}$ represents the deviation from 1g we accept when including accelerometer estimates. Suggested values are:
  * 0.05 for well calibrated, low noise accelerometers
  * 0.20 for poorly calibrated, noisy accelerometers


