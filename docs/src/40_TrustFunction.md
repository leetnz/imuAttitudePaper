### Trust function

The trust function provides the following:

$$
f^{trust}(\hat{a}^{accel}_k) = 
\begin{cases}
    F^{max},& \text{if } \left \| \hat{a}^{accel}_k \right \| = g\\
    0,      & \text{if } \left(\left \| \hat{a}^{accel}_k \right \| - g\right) \ge gK^{tol} \\
    0,      & \text{if } \left(g - \left \| \hat{a}^{accel}_k \right \|\right) \ge gK^{tol} 
\end{cases}
$$

Where:

* $g$ is the gravity constant $9.81  ms^{-1}$
* $K^{tol}$ is the deviation from $g$ where we reject all accelerometer data
* $F^{max}$ is the maximum output of the trust function

A trust function with a linear decay from $g$ is:

$$
f^{trust}(\hat{a}^{accel}_k) = F^{max} \max\left(0,
1 - \frac{1}{K^{tol}}\left( \frac{\left \| \hat{a}^{accel}_k \right \|}{g} - 1\right)\right)
$$

With:

* $F^{max} = 1$
* $K^{tol} = 0.2$ (20% deviation)

We get:

![Linear trust function](src/images/40_trustFunction.png)

#### Optimization for embedded systems

A minor optimization can be made to the trust function to make it run faster on embedded systems. The absolute acceleration is given as:

$$
\left \| \hat{a}^{accel}_k \right \| = \sqrt{
        \ddot{x}^{accel}_k \times \ddot{x}^{accel}_k +
        \ddot{y}^{accel}_k \times \ddot{y}^{accel}_k +
        \ddot{z}^{accel}_k \times \ddot{z}^{accel}_k} \\
$$

The square root operation can be removed by linerizing $\frac{\left \| \hat{a}^{accel}_k \right \|}{g}$ about $g$.

If we let:

$$
u_k = \ddot{x}^{accel}_k \times \ddot{x}^{accel}_k +
    \ddot{y}^{accel}_k \times \ddot{y}^{accel}_k +
    \ddot{z}^{accel}_k \times \ddot{z}^{accel}_k
$$

Then:

$$
\frac{\left \| \hat{a}^{accel}_k \right \|}{g} = \frac{\sqrt{u_k}}{g}
$$

Linearizing this about $u_k = g^2$ gives us:

$$
\frac{\left \| \hat{a}^{accel}_k \right \|}{g} \approx 1 + \frac{u_k - g}{2g^2}
$$

Substituting this into $f^{trust}(\hat{a}^{accel}_k)$ gives a computationally cheaper trust function:

$$
f^{trust}(\hat{a}^{accel}_k) = F^{max} \max\left(0,
1 - \frac{1}{2 K^{tol}}\left( \frac{u_k}{g} - 1 \right)\right)
$$

The resulting approximation carries up to 10% error from our ideal trust function. In practice this doesn't impact the behavior of the complimentary filter in any meaningful way:

![Approximating the trust function](src/images/40_optimized.png)




