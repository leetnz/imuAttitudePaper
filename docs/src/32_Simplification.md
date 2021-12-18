### Simplifying the estimator

There are two aspects of the Kalman filter in it's default form which aren't particularly useful for our estimator:

* The covariance matrix
* Including $\dot{\phi}$ in our observations


#### Simplification 1: Covariance Matrix

The covariance matrix $\Sigma$ doesn't help us much. The problems are:

* If we have a bad accelerometer reading - we can't use it, so tracking covariance isn't ideal
* After a period of bad accelerometer readings, we don't want our covariance to blow up to a point where the next "valid" accelerometer reading is trusted in it's entirety. This is because it is possible to get invalid accelerometer readings which look valid, so they need to be filtered adequately.

#### Simplification 2: We only care about $\phi$

The observation step doesn't pay attention to $\dot{\phi}$.

#### Simplification 3: Replacing the Kalman gain with a trust function

The two simplifications above have a direct implication on computing the Kalman gain.

If we allow $Q$ to equal, (note, we don't estimate noise on $\dot{\phi}$ since it is not involved in observations):

$$
\begin{bmatrix}
    q_k & 0 \\
    0 & 0\\
\end{bmatrix}
$$

Then the Kalman gain computation

$$
K_{k} = \bar{\Sigma}_{k}C^T(C\bar{\Sigma}_{k}C^T + Q)^{-1}
$$

Simplifies to:

$$
\begin{split}
K_{k} &=
    \begin{bmatrix}
        r^{11}_k & r^{12}_k \\
        r^{21}_k & r^{22}_k \\
    \end{bmatrix}
    \begin{bmatrix}
        1 & 0 \\
        0 & 0 \\
    \end{bmatrix}
    \left(
        \begin{bmatrix}
            1 & 0 \\
            0 & 0 \\
        \end{bmatrix}
        \begin{bmatrix}
            r^{11}_k & r^{12}_k \\
            r^{21}_k & r^{22}_k \\
        \end{bmatrix}
        \begin{bmatrix}
            1 & 0 \\
            0 & 0 \\
        \end{bmatrix} + 
        \begin{bmatrix}
            q_k & 0 \\
            0 & 0\\
        \end{bmatrix}
    \right)^{-1}
    \\
    &=
    \begin{bmatrix}
        \frac{r^{11}_k}{r^{11}_k + q_k} & 0 \\
        0 & 0\\
    \end{bmatrix}
\end{split}
$$

Given that the covariance of $R$ is constant, but $q_k$ depends on how much we trust the measured acceleration, a more meaningful equation discards $R$'s contribution as meaningless scaling and instead focusses on a trust function, where $\hat{a}^{accel}_k$ is the accelerometer's measurements on step $k$:

$$
\hat{a}^{accel}_k = 
    \begin{bmatrix}
        \ddot{x}^{accel}_k \\
        \ddot{y}^{accel}_k \\
        \ddot{z}^{accel}_k \\
    \end{bmatrix}
$$

$$
K_{k} =
\begin{bmatrix}
    f^{trust}(\hat{a}^{accel}_k) & 0 \\
    0 & 0\\
\end{bmatrix}
$$

Our final estimate of $\mu_k$ becomes a lot simpler too: 

$$
\begin{split}
\hat{\mu}_{k} &= \bar{\hat{\mu}}_{k} + K_{k}(z_k - C\bar{\hat{\mu}}_{k}) \\
              &= 
    \begin{bmatrix}
        \bar{\phi}_k \\
        \dot{\phi}^{gyro}_k \\
    \end{bmatrix} +
    \begin{bmatrix}
        f^{trust}(\hat{a}^{accel}_k) & 0 \\
        0 & 0\\
    \end{bmatrix} \left(
        \begin{bmatrix}
            \phi^z_k \\
            \dot{\phi}^{gyro}_k \\
        \end{bmatrix} - 
        \begin{bmatrix}
            \bar{\phi_k} \\
            \dot{\phi}^{gyro}_k \\
        \end{bmatrix}
    \right) \\
        &= 
    \begin{bmatrix}
        \bar{\phi}_k  + f^{trust}(\hat{a}^{accel}_k) \times \left(\phi^z_k - \bar{\phi}_k\right) \\
        \dot{\phi}^{gyro}_k \\
    \end{bmatrix} \\
        &= 
    \begin{bmatrix}
        \bar{\phi}^{gyro}_k  + f^{trust}(\hat{a}^{accel}_k) \times \left(\bar{\phi}^{accel}_k - \bar{\phi}^{gyro}_k\right) \\
        \dot{\phi}^{gyro}_k \\
    \end{bmatrix}
\end{split}
$$

In this form, the trust function simply outputs a value in range $[0, 1]$ which determines how much we trust our observations. When it is $0$ we only trust the system equations (gyroscope estimator), when it is $1$ we only trust the observations (accelerometer).

This is also known as a complimentary filter with the exception that the gain is not constant. The gyroscopic measurements represent the high-pass elements (because they include feedback), and the accelerometer measurements represent the low-pass elements.

A paper [Quadrotor attitude determination: A comparison study](https://www.researchgate.net/publication/309332785_Quadrotor_attitude_determination_A_comparison_study) demonstrates similar performance between a Kalman filter and a complimentry filter. This isn't too surprising when considering that without knowing intimate details about an IMU's offsets and coupling profile, the best estimates from a Kalman filter effectively reduces to a complimentry filter in this application.
