module RIdb

using Interpolations
using HDF5

export aluminum,
       air,
       bk7,
       chrome,
       dummy,
       glass,
       gold,
       silicon,
       silicontemperature,
       silver,
       sno2f,
       h2o,
       etoh,
       fusedsilicauv,
       fusedsilicauv2,
       Info

function Info()
    tmp1 = "\n " *
        "\n " *
        "\n Available functions for materials index of refraction:" *
        "\n " *
        "\n     aluminum(λ), λ ∈ [4.15, 31000] (nm)" *
        "\n     air(λ), λ ∈ any (nm)" *
        "\n     bk7(λ), λ ∈ [191, 1239] (nm)" *
        "\n     chrome(λ), λ ∈ [207, 1240] (nm)" *
        "\n     dummy(λ), λ ∈ any (nm)" *
        "\n     glass(λ), λ ∈ [0.25, 2.5] (μm)" *
        "\n     gold(λ), λ ∈ [34.15, 10240] (nm)" *
        "\n     silicon(λ), λ ∈ [163.15, 25000] (nm)" *
        "\n     silicontemperature(λ, T), λ ∈ [264, 826.5], T ∈ [20, 450]" *
        "\n     silver(λ), λ ∈ [0.124, 9919] (nm)" *
        "\n     sno2f(λ), λ ∈ [308.25, 2490.9] (nm), fluor doped!" *
        "\n     h2o(λ), λ ∈ [10.0, 1e10] (nm)" *
        "\n     etoh(λ), λ ∈ [476.5, 830] (nm)" *
        "\n     fusedsilicauv(λ), λ ∈ [0.21, 6.7] (μm)" *
        "\n     fusedsilicauv2(λ), λ ∈ [170.0, 3240] (nm)" *
        "\n "
    return println(tmp1)
end

"""Read the HDF5 file with the database. Internal use."""
function read_RIfiles_DB(material)
    datapath = joinpath(@__DIR__, "..", "data/")
    readf = h5open(joinpath(datapath, "RefractiveIndicesDB.h5"), "r") do file
        read(file, material)
    end
    readf
end

"""Build interpolation objects. Internal use."""
function build_interpolation(x, y)
    knots = (sort(vec(x)),)
    return interpolate(knots, vec(y), Gridded(Linear()))
end

"""

    Returns the index of refraction of air in complex format, for a given range of wavelengths in nm.

        N = RIdb.air(λ)

            λ: wavelength range (nm)
            N: complex index of refraction

"""
function air(λ::AbstractVector{T}) where {T<:Real}
    return 1.00029.*ones(length(λ)) .+ im.*zeros(length(λ))
end

"""

    Returns the index of refraction for constants values in complex format, for a given range of wavelengths in nm.

        N = RIdb.dummy(λ, a, b)

            λ: wavelength range (nm)
            a: real part constant value
            b: imaginary part constant value
            N: complex index of refraction

"""
function dummy(λ::AbstractVector{T}, x::S, y::S) where {T<:Real, S<:Real}
    return ones(length(λ)).*(x .+ im.*y)
end

"""

    Returns the index of refraction of glass in complex format, for a given range of wavelengths in μm, using the Sellmeier equation.

        N = RIdb.glass(λ)

            λ: wavelength range (μm), ∈ [0.25, 2.5] (μm)
            N: complex index of refraction

    Source: http://refractiveindex.info, https://en.wikipedia.org/wiki/Sellmeier_equation

"""
function glass(λ::AbstractVector{T}) where {T<:Real}
    λ = λ.^2
    return sqrt.(Complex.(1.0 .+ (1.03961212.*λ./(λ .- 0.00600069867)) .+ (0.231792344.*λ./(λ .- 0.0200179144)) .+ (1.01046945.*λ./(λ .- 103.560653))))
end

"""

    Returns the index of refraction of fused silica UV in complex format, for a given range of wavelengths in μm, using the Sellmeier equation.

        N = RIdb.fusedsilicauv(λ)

            λ: wavelength range (μm), ∈ [0.21, 6.7] (μm)
            N: complex index of refraction

    Sources: http://refractiveindex.info, https://en.wikipedia.org/wiki/Sellmeier_equation


"""
function fusedsilicauv(λ::AbstractVector{T}) where {T<:Real}
    λ = λ.^2
    return sqrt.(Complex.(1.0 .+ (0.6961663.*λ./(λ .- 0.0684043)) .+ (0.4079426.*λ./(λ .- 0.1162414)) .+ (0.8974794.*λ./(λ .- 9.896161))))
end

"""

    Returns the index of refraction of liquid ethanol in complex format, for a given range of wavelengths in nm.

        N = RIdb.etoh(λ)

            λ: wavelength range (nm), ∈ [476.5, 830] (nm)
            N: complex index of refraction

    Source: http://refractiveindex.info/

"""
function etoh(λ::AbstractVector{T}) where {T<:Real}
    λ .*= 1e6
    return 1.35265 .+ 0.00306./(λ.^2) .+ 0.00002./(λ.^4) .+ im.*zeros(λ)
end

"""

    Returns the index of refraction of aluminum in complex format, for a given range of wavelengths in nm.

        N = RIdb.aluminum(λ)

            λ: wavelength range (nm), ∈ [4.15, 31000]
            N: complex index of refraction

    Source: http://www-swiss.ai.mit.edu/~jaffer/FreeSnell/nk.html

"""
function aluminum(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("aluminum")
    spl_n = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of BK7 in complex format, for a given range of wavelengths in nm.

        N = RIdb.bk7(λ)

            λ: wavelength range (nm), ∈ [191, 1239] (nm)
            N: complex index of refraction

    Source: http://www-swiss.ai.mit.edu/~jaffer/FreeSnell/nk.html

"""
function bk7(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("bk7")
    spl_n = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of chrome in complex format, for a given range of wavelengths in nm.

        N = RIdb.chrome(λ)

            λ: wavelength range (nm), ∈ [207, 1240] (nm)
            N: complex index of refraction

    Source: http://www-swiss.ai.mit.edu/~jaffer/FreeSnell/nk.html

"""
function chrome(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("chrome")
    spl_n = build_interpolation(vec(readf["lambda"]), vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]), vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of gold in complex format, for a given range of wavelengths in nm.

        N = RIdb.gold(λ)

            λ: wavelength range (nm), ∈ [34.15, 10240] (nm)
            N: complex index of refraction

    Source: http://www-swiss.ai.mit.edu/~jaffer/FreeSnell/nk.html

"""
function gold(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("gold")
    spl_n = build_interpolation(vec(readf["lambda"]), vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]), vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of crystalline silicon in complex format, for a given range of wavelengths in nm.

        N = RIdb.silicon(λ)

            λ: wavelength range (nm), ∈ [163.15, 25000] (nm)
            N: complex index of refraction

    Source: http://www-swiss.ai.mit.edu/~jaffer/FreeSnell/nk.html

"""
function silicon(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("silicon")
    spl_n = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of crystalline silicon in complex format, for a given range of wavelengths in nm and a one temperature value.

        N = RIdb.silicontemperature(λ, T)

            λ: wavelength range (nm), ∈ [264, 826.5]
            T: value of temperature (C), ∈ [20, 450] (scalar)
            N: complex index of refraction

    Source: http://refractiveindex.info/

"""
function silicontemperature(λ::AbstractVector{T}, t::S) where {T<:Real, S<:Real}
    (20 < t < 450) || throw("Temperature range is invalid: 20 < T < 450 in C.")
    readf = read_RIfiles_DB("silicontemperature")
    lambda = sort(vec(readf["lambda"]))
    # https://discourse.julialang.org/t/a-question-on-extrapolation-with-interpolations-jl/3669/4
    lambda = [prevfloat(lambda[1]);lambda[2:end-1];nextfloat(lambda[end])]
    knots = (lambda,)
    spl_n20 = interpolate(knots, vec(readf["n20"]), Gridded(Linear()))
    aux_n20 = spl_n20.(λ)
    spl_k20 = interpolate(knots, vec(readf["k20"]), Gridded(Linear()))
    aux_k20 = spl_k20.(λ)
    spl_n450 = interpolate(knots, vec(readf["n450"]), Gridded(Linear()))
    aux_n450 = spl_n450.(λ)
    spl_k450 = interpolate(knots, vec(readf["k450"]), Gridded(Linear()))
    aux_k450 = spl_k450.(λ)
    dndt = (aux_n450 .- aux_n20)./(450.0 - 20.0)
    dkdt = (aux_k450 .- aux_k20)./(450.0 - 20.0)
    if t < 215.0
        spl_n = interpolate(knots, vec(readf["n20"]), Gridded(Linear()))
        aux = spl_n.(λ).*(1.0 .+ dndt.*(t - 20.0))
        spl_k = interpolate(knots, vec(readf["k20"]), Gridded(Linear()))
        aux2 = spl_k.(λ).*(1.0 .+ dkdt.*(t - 20.0))
    else
        spl_n = interpolate(knots, vec(readf["n450"]), Gridded(Linear()))
        aux = spl_n.(λ).*(1.0 .+ dndt.*(t - 20.0))
        spl_k = interpolate(knots, vec(readf["k450"]), Gridded(Linear()))
        aux2 = spl_k.(λ).*(1.0 .+ dkdt.*(t - 20.0))
    end
    return aux .+ im.*aux2
end

"""

    Returns the index of refraction of silver in complex format, for a given range of wavelengths in nm.

        N = RIdb.silver(λ)

            λ: wavelength range (nm), ∈ [0.124, 9919] (nm)
            N: complex index of refraction

    Source: http://www-swiss.ai.mit.edu/~jaffer/FreeSnell/nk.html

"""
function silver(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("silver")
    spl_n = build_interpolation(vec(readf["lambda"]), vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]), vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of SnO2:F in complex format, for a given range of wavelengths in nm.

        N = RIdb.sno2f(λ)

            λ: wavelength range (nm), ∈ [308.25, 2490.9] (nm)
            N: complex index of refraction

    Source: Mater. Res. Soc. Symp. Proc., 426, (1996) 449

"""
function sno2f(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("sno2f")
    spl_n = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]).*1e9, vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of liquid water in complex format, for a given range of wavelengths in nm.

        N = RIdb.h2o(λ)

            λ: wavelength range (nm), ∈ [10.0, 1e10] (nm)
            N: complex index of refraction

    Source: http://refractiveindex.info/

"""
function h2o(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("h2o")
    spl_n = build_interpolation(vec(readf["lambda"]).*1e3, vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]).*1e3, vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end

"""

    Returns the index of refraction of fused silica UV graded in complex format, for a given range of wavelengths in nm. This function accounts for lower wavelengths than fusedsilicauv.

        N = RIdb.fusedsilicauv2(λ)

            λ: wavelength range (nm), ∈ [170.0, 3240] (nm)
            N: complex index of refraction

    Source: http://www.janis.com/Libraries/Window_Transmissions/FusedSilicaUVGrade_SiO2_TransmissionCurveDataSheet.sflb.ashx

"""
function fusedsilicauv2(λ::AbstractVector{T}) where {T<:Real}
    readf = read_RIfiles_DB("fusedsilicauv")
    spl_n = build_interpolation(vec(readf["lambda"]), vec(readf["n"]))
    spl_k = build_interpolation(vec(readf["lambda"]), vec(readf["k"]))
    return spl_n.(λ) .+ im.*spl_k.(λ)
end


end # module RIdb
