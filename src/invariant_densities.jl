########################################################################################################
########################################################################################################
# Simulation of different stationary, invariant densities of SDE limit equations obtained through
# homogenization theory and their derivatives with respect to sought-after parameters.
########################################################################################################
########################################################################################################
# Jaroslav Borodavka, 13.08.2024

########################################################################################################
## invariant densities and their derivatives
########################################################################################################

# transformation specifically used for HCubature.jl to transform integration domain
t(y) = y/(1-y^2)
dt(y) = (1+y^2)/(1-y^2)^2

# invariant density defined through a potential
@doc raw"""
    μ(x, ϑ, Σ, V)

Return function value of invariant density at `x` defined through a potential `V` and given parameter values `ϑ` and `Σ`.

The invariant density is given by the formula
```math
\begin{aligned}
    \mu(x, \vartheta, \Sigma, V) = \frac{1}{Z(ϑ, Σ)} \exp\left( -\frac{\vartheta}{\Sigma} V(x) \right), \quad x \in \R,
\end{aligned}
```
where ``V`` is potential on ``\R``, e.g. ``V(x) = x^4/4 - x^2/2``, and ``Z(ϑ, Σ)>0`` is a normalization constant.

---
# Arguments
- `x::Real`:            argument ``x`` at which to evaluate the function.
- `ϑ::Real`:            positive drift coefficient ``\vartheta``.
- `Σ::Real`:            positive diffusion coefficient ``\Sigma``.
- `V`:                  defining potential function ``V``.

---
# Examples
```julia-repl
julia> lines(range(-5, 5, 1000), map(y -> μ(y, 1, 1, x -> x^2/2), range(-5, 5, 1000)))
```
"""
function μ(x, ϑ, Σ, V)
    # normalization constant
    Z = HCubature.hquadrature(y -> exp(-ϑ/Σ*V(t(y)))dt(y), -1, 1)[1]
    1/Z*exp(-ϑ/Σ*V(x))
end

# derivative of invariant density with respect to ϑ
@doc raw"""
    ∂ϑ_μ(x, ϑ, Σ, V)

Return function value of derivative of invariant density with respect to drift parameter `ϑ` at `x` for given parameter values `ϑ` and `Σ` and potential `V`.

The derivative of the invariant density with respect to the drift parameter is given by the formula
```math
\begin{aligned}
    \partial_ϑ \,  \mu(x, \vartheta, \Sigma, V) &= -\mu(x, \vartheta, \Sigma, V) \left( \frac{V(x)}{\Sigma} + \frac{\partial_\vartheta Z(ϑ, Σ)}{Z(ϑ, Σ)} \right), \quad x \in \R, \\[0.5cm]
    \partial_\vartheta Z(ϑ, Σ) &= -\frac{1}{\Sigma} \int_\R V(y) \exp\left(-\frac{\vartheta}{\Sigma} V(y)\right) \, dy,
\end{aligned}
```
where ``V`` is a potential on ``\R``, e.g. ``V(x) = x^2/2 - x^4/4``, and ``Z(ϑ, Σ)>0`` is a normalization constant.

---
# Arguments
- `x::Real`:            argument ``x`` at which to evaluate the function.
- `ϑ::Real`:            positive drift coefficient ``\vartheta``.
- `Σ::Real`:            positive diffusion coefficient ``\Sigma``.
- `V`:                  defining potential function ``V``.

---
# Examples
```julia-repl
julia> lines(range(-5, 5, 1000), map(x -> ∂ϑ_μ(x, 1, 1, x -> x^2/2), range(-5, 5, 1000)))
```
"""
function ∂ϑ_μ(x, ϑ, Σ, V)
    # normalization constant
    Z = HCubature.hquadrature(y -> exp(-ϑ/Σ*V(t(y)))dt(y), -1, 1)[1]
    # derivative of normalization constant of invariant density with respect to drift parameter
    ∂ϑ_Z = -1/Σ*HCubature.hquadrature(y -> V(t(y))exp(-ϑ/Σ*V(t(y)))dt(y), -1, 1)[1]
    # using the normalization constant here again instead of μ(x, ϑ, Σ, V) reduces computational cost
    -1/Z*exp(-ϑ/Σ*V(x))*(V(x)/Σ + ∂ϑ_Z/Z)
end

# derivative of invariant density with respect to Σ
@doc raw"""
    ∂Σ_μ(x, ϑ, Σ, V)

Return function value of derivative of invariant density with respect to diffusion parameter `Σ` at `x` for given parameter values `ϑ` and `Σ` and potential `V`.

The derivative of the invariant density with respect to the diffusion parameter is given by the formula
```math
\begin{aligned}
    \partial_\Sigma \,  \mu(x, \vartheta, \Sigma, V) &= \mu(x, \vartheta, \Sigma, V) \left( \frac{\vartheta V(x)}{\Sigma^2} - \frac{\partial_\Sigma Z(ϑ, Σ)}{Z(ϑ, Σ)} \right), \quad x \in \R, \\[0.5cm]
    \partial_\Sigma Z(\vartheta, \Sigma) &= \frac{\vartheta}{\Sigma^2} \int_\R V(y) \exp\left(-\frac{\vartheta}{\Sigma} V(y)\right) \, dy,
\end{aligned}
```
where ``V`` is a potential on ``\R``, e.g. ``V(x) = x^2/2 - x^4/4``, and ``Z(ϑ, Σ)>0`` is a normalization constant.

---
# Arguments
- `x::Real`:            argument ``x`` at which to evaluate the function.
- `ϑ::Real`:            positive drift coefficient ``\vartheta``.
- `Σ::Real`:            positive diffusion coefficient ``\Sigma``.
- `V`:                  defining potential function ``V``.

---
# Examples
```julia-repl
julia> lines(range(-5, 5, 1000), map(x -> ∂Σ_μ(x, 1, 1, x -> x^2/2), range(-5, 5, 1000)))
```
"""
function ∂Σ_μ(x, ϑ, Σ, V)
    # normalization constant
    Z = HCubature.hquadrature(y -> exp(-ϑ/Σ*V(t(y)))dt(y), -1, 1)[1]
    # derivative of normalization constant of invariant density with respect to diffusion parameter
    ∂Σ_Z = ϑ/Σ^2*HCubature.hquadrature(y -> V(t(y))exp(-ϑ/Σ*V(t(y)))dt(y), -1, 1)[1]
    # using the normalization constant here again instead of μ(x, ϑ, Σ, V) reduces computational cost
    1/Z*exp(-ϑ/Σ*V(x))*(ϑ*V(x)/Σ^2 - ∂Σ_Z/Z)
end