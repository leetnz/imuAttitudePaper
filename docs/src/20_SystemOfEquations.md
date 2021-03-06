## System of equations

Here we present an imaginary - but useful - system for simulating an attitude estimator which operates in a 2-D plane.

$$
\underset{\dot{X}}{
    \begin{bmatrix}
        \dot{y} \\
        \ddot{y} \\
        \dot{z} \\
        \ddot{z} \\
        \dot{\phi} \\
        \ddot{\phi} \\
    \end{bmatrix}
} = \underset{A}{
    \begin{bmatrix}
        0 & 1    & 0 & 0    & 0 & 0 \\
        0 & -d_y & 0 & 0    & 0 & 0 \\
        0 & 0    & 0 & 1    & 0 & 0 \\
        0 & 0    & 0 & -d_z & 0 & 0 \\
        0 & 0    & 0 & 0    & 0 & 1 \\
        0 & 0    & 0 & 0    & 0 & -d_{\phi}
    \end{bmatrix}}
\underset{X}{
    \begin{bmatrix}
        y \\
        \dot{y} \\
        z \\
        \dot{z} \\
        \phi \\
        \dot{\phi} \\
    \end{bmatrix}}
+ \underset{B}{
    \begin{bmatrix}
        0           & 0           & 0 \\
        \frac{1}{M} & 0           & 0 \\
        0           & 0           & 0 \\
        0           & \frac{1}{M} & 0 \\
        0           & 0           & 0 \\
        0           & 0           & \frac{1}{I}
    \end{bmatrix}}
\underset{U}{
    \begin{bmatrix}
        F_y \\
        F_z \\
        \tau_{\phi}
    \end{bmatrix}}
$$

Where:

* $X$ is the system state
* $y$ and $z$ are the translational dimensions making up the y-z plane
* $\phi$ is the angle about the $x$ axis perpendicular to the y-z plane
* $d_y$ and $d_z$ are translational damping in $y$ and $z$ respectively
* $d_\phi$ is angular damping
* $M$ and $I$ are the point mass and inertia about $\phi$ of our object
* $U$ are our system inputs:
  * $F_y$ and $F_z$ are forces in $y$ and $z$ respectively
  * $\tau_{\phi}$ is the torque applied to the $x$ axis

### IMU equations

We specify two frames:

* $F^i$ the inertial frame, where:

$$
    \begin{bmatrix}
        y^i \\
        z^i \\
    \end{bmatrix} = 
    \begin{bmatrix}
        y \\
        z \\
    \end{bmatrix}
$$

* $F^s$ the sensor frame, which is equal to $F^i$ when $\phi = 0$

The transformation between the two frames is:

$$
    \begin{bmatrix}
        y^s \\
        z^s \\
    \end{bmatrix} = 
    \begin{bmatrix}
        \cos(\phi) & \sin(\phi) \\
        -\sin(\phi) & \cos(\phi) \\
    \end{bmatrix}
    \begin{bmatrix}
        y^i \\
        z^i \\
    \end{bmatrix}
$$

#### Accelerometer

The accelerometer measurement equation for any given sample $n$ is given as:

$$
\begin{bmatrix}
    \ddot{y}^{accel}_k \\
    \ddot{z}^{accel}_k \\
\end{bmatrix} = 
\begin{bmatrix}
    \cos(\phi) & \sin(\phi) \\
    -\sin(\phi) & \cos(\phi) \\
\end{bmatrix}
\begin{bmatrix}
    \ddot{y}^i_k \\
    \ddot{z}^i_k + 9.81 \\
\end{bmatrix} +
\begin{bmatrix}
    \ddot{y}^{noise}_k \\
    \ddot{z}^{noise}_k \\
\end{bmatrix} +
\begin{bmatrix}
    \ddot{y}^{offset} \\
    \ddot{z}^{offset} \\
\end{bmatrix}
$$

Where:

* $\ddot{y}^{noise}_k$ and $\ddot{z}^{noise}_k$ vary every update
* $\ddot{y}^{offset}$ and $\ddot{z}^{offset}$ are treated as constant measurement errors

#### Gyroscope

Rate measurements are independent of orientation so we only add noise and offset:

$$
\dot{\phi}^{gyro}_k = \dot{\phi}_k + \dot{\phi}^{noise}_k + \dot{\phi}^{offset}
$$
