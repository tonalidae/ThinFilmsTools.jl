# Sensors and Actuators B 149 (2010) 189-193

# Load modules
using Plots, LaTeXStrings
pyplot(reuse=false, grid=false)
closeall()
using ThinFilmsTools

function main()
    # Define beam
    λ = LinRange(400, 1000, 500) # wavelength range [nm]
    θ = [0.] # angle of incidence [degrees]
    beam = PlaneWave(λ, θ)
    # Define layers with d=1/4 by default
    l0 = LayerTMMO1DIso(RIdb.air(beam.λ))
    l1 = LayerTMMO1DIso(RI.looyengaspheresbin(0.86,RIdb.air(beam.λ),RIdb.silicon(beam.λ)); type=:OT)
    l2 = LayerTMMO1DIso(RI.looyengaspheresbin(0.54,RIdb.air(beam.λ),RIdb.silicon(beam.λ)); type=:OT)
    l3 = LayerTMMO1DIso(RIdb.glass(beam.λ./1e3))
    layers = vec([l0 l1 l2 l1 l2 l1 l2 l1 l2 repeat([l1], 1, 10) l2 l1 l2 l1 l2 l1 l2 l1 l3])
    # Reference wavelength
    λ0 = 730.
    # call main script
    return TMMO1DIsotropic(beam, layers; λ0=λ0, emfflag=true, h=10)
end

sol = main()

# plot the R, T and A spectra
plot(TMMOPlotSpectra1D(),
     sol.Beam.λ, [sol.Spectra.Rp, sol.Spectra.Tp, 1.0.-(sol.Spectra.Rp.+sol.Spectra.Tp)], label=["Reflectance" "Transmittance" "Absorbance"], line=([:solid :dash :dashdot]), xlims=(sol.Beam.λ[1], sol.Beam.λ[end]), yaxis=("Transmittance", (0.,1.0)));
gui()

plot(TMMOPlotEMF2D(),
     sol.Beam.λ, sol.Misc.ℓ, sol.Field.emfp[:,1,:])
gui()

# plot the refractive index profile
TMMOPlotNprofile(sol)
