### Trust function

A trust function must meet the following requirements:

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

The trust function plot below demonstrates:

* $F^{max} = 1$
* $K^{tol} = 0.2$ (20% deviation)

![Linear trust function](src/images/33_trustFunction.png)

#### Optimization for embedded systems

A minor optimization can be made to the trust function to make it run faster on embedded systems. The absolute acceleration is given as:

$$
\left \| \hat{a}^{accel}_k \right \| = \sqrt{(\ddot{x}^{accel}_k)^2 + (\ddot{y}^{accel}_k)^2 + (\ddot{z}^{accel}_k)^2}
$$

The square root operation can be removed by linerizing $\frac{\left \| \hat{a}^{accel}_k \right \|}{g}$ about $g$.

If we let:

$$
\left \| \hat{a}^{accel}_k \right \|^2 = (\ddot{x}^{accel}_k)^2 + (\ddot{y}^{accel}_k)^2 + (\ddot{z}^{accel}_k)^2
$$

Then:

$$
\frac{\left \| \hat{a}^{accel}_k \right \|}{g} = \frac{\sqrt{\left \| \hat{a}^{accel}_k \right \|^2}}{g}
$$

Linearizing this about $\left \| \hat{a}^{accel}_k \right \|^2 = g^2$ gives us:

$$
\frac{\left \| \hat{a}^{accel}_k \right \|}{g} \approx 1 + \frac{\left \| \hat{a}^{accel}_k \right \|^2 - g}{2g^2}
$$

Substituting this into $f^{trust}(\hat{a}^{accel}_k)$ gives a computationally cheaper trust function:

$$
f^{trust}(\hat{a}^{accel}_k) = F^{max} \max\left(0,
1 - \frac{1}{2 K^{tol}}\left( \frac{\left \| \hat{a}^{accel}_k \right \|^2}{g} - 1 \right)\right)
$$

As shown in the figure below, the resulting approximation carries up to 10% error from our ideal trust function. In practice this doesn't impact the behavior of the complimentary filter in any meaningful way.

![Approximating the trust function](src/images/33_optimized.png)




