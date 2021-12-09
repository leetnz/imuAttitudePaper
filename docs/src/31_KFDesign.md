### Kalman Filter

#### The Kalman Filter Algorithm

We assume we have a system of equations:

$$
\hat{x}_{k} = A \hat{x}_{k-1} + B \hat{u}_{k}
$$

Where:

* $\underset{n\times 1}{\hat{x}}$ is the system's state
* $\underset{n\times n}{A}$ represents the change in system state between iterations
* $\underset{m\times 1}{\hat{u}}$ are system inputs
* $\underset{n\times m}{B}$ represents the change is system state due to inputs

And a set of observations:

$$
\hat{z}_{k} = C \hat{x}_{k} + D \hat{u}_{k}
$$

Where:

* $\underset{p\times 1}{\hat{z}}$ are the measured observations
* $\underset{p\times n}{C}$ describes how the state $\hat{x}$ maps to the observation
* $\underset{p\times m}{D}$ represents the change in observation due to inputs

*note: A, B, u, and state x are not the same as in the system of equations. In this case we are dealing with a digital estimator, whereas those equations are for a continuous system.*

Estimates of state $\underset{n\times 1}{\hat{x}}$ are represented as a gaussian distribution with:

* a mean, $\underset{n\times 1}{\hat{\mu}}$
* a variance, $\underset{n\times n}{\Sigma}$.

Given inputs from the previous iteration:

* $\hat{\mu}_{k-1}$ - the estimated mean
* $\Sigma_{k-1}$ - the estimated covariance matrix
* $\hat{u}_{k}$ - system inputs
* $\hat{z}_{k}$ - measured observations

Predict the distribution using the system model:

$$ 
\begin{split}
\bar{\hat{\mu}}_{k} &= A \hat{\mu}_{k-1} + B \hat{u}_{k} \\
\bar{\Sigma}_{k} &= A \Sigma_{k-1} A^T + R
\end{split}
$$

Calculate the Kalman Gain $K_k$:

$$
K_{k} = \bar{\Sigma}_{k}C^T(C\bar{\Sigma}_{k}C^T + Q)^{-1}
$$

Estimate the distribution by combining the observations with the predicted state:

$$
\begin{split}
\hat{\mu}_{k} &= \bar{\hat{\mu}}_{k} + K_{k}(z_k - C\bar{\hat{\mu}}_{k}) \\
\Sigma_{k} &= (I - K_{k} C)\bar{\Sigma}_{k}
\end{split}
$$

#### Estimator's system of equations

We would like a generic estimator which only uses IMU meaasurements - this means we have no information about forces or torques being applied to the system.

The state we care about is:

$$
\hat{x} = \begin{bmatrix}
    \theta \\
    \dot{\theta} \\
\end{bmatrix}
$$

Firstly, for state prediction, we end up using the gyroscope measurements for the inputs $u$:

$$
\begin{bmatrix}
    \bar{\theta}_k \\
    \bar{\dot{\theta}}_k \\
\end{bmatrix} = 
\begin{bmatrix}
    1 & \frac{\Delta t_k}{2} \\
    0 & 0 \\
\end{bmatrix}
\begin{bmatrix}
    \theta_{k-1} \\
    \dot{\theta}_{k-1} \\
\end{bmatrix} + 
\begin{bmatrix}
    \frac{\Delta t_k}{2} \\
    1 \\
\end{bmatrix}
    \dot{\theta}^{gyro}_{k}
$$

This is equivalent to the gyroscope-only estimator presented in the introduction.

Next, the observation is handled using accelerometer measurements:

$$
\bar{\theta}_{K}^{accel} = \tan^{-1}\left(\frac{\ddot{y}^{accel}_k}{\ddot{z}^{accel}_k}\right)
$$

$$
\begin{bmatrix}
    \theta^z_k \\
    \dot{\theta}^z_k \\
\end{bmatrix} = 
\begin{bmatrix}
    1 & 0 \\
    0 & 0 \\
\end{bmatrix}
\begin{bmatrix}
    \theta_{k}^{accel} \\
    0
\end{bmatrix} +
\begin{bmatrix}
    0 \\
    1 \\
\end{bmatrix}
\dot{\theta}^{gyro}_{k}
$$

We will then need to tune matrices $Q$ and $R$ to compute reasonable Kalman gains for various measurements.

$Q$ will need to change on every step, because it should reflect the trust we have in the acceleration measurements - which will be zero when the magnitude of acceleration is not close to 9.81.
