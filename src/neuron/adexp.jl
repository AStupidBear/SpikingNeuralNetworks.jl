"""
Julia SNN Implementation of AdExp Neuron.
[Adaptive_exponential_integrate and fire neuron](http://www.scholarpedia.org/article/Adaptive_exponential_integrate-and-fire_model)
Dr. Wulfram Gerstner
Romain Brette, Ecole Normale Supérieure, Paris, France
"""


@snn_kw struct ADEXParameter{FT=Float32}
    a::FT = 4.0
    b::FT = 0.0805
    cm::FT = 0.281
    v_rest::FT = -70.6
    tau_m::FT = 9.3667
    tau_w::FT = 144.0
    v_thresh::FT = -50.4
    delta_T::FT = 2.0
    v_spike::FT = -40.0
    v_reset::FT = -70.6
    spike_delta::FT = 30
end
@snn_kw mutable struct AD{VFT=Vector{Float32},VBT=Vector{Bool}}
    param::ADEXParameter = ADEXParameter()

@with_kw mutable struct AD
    param::ADEXParameter = ADEXParameter(a,
                                        b,
                                        cm,
                                        v_rest,
                                        tau_m,
                                        tau_w,
                                        v_thresh,
                                        delta_T,
                                        v_spike,
                                        v_reset,
                                        spike_delta)
    N::SNNInt = 1
    cnt::SNNInt = 2
    v::Vector{SNNFloat} = fill(param.v_rest, N)
    w::Vector{SNNFloat} = zeros(N)
    fire::Vector{Bool} = zeros(Bool, N)
    I::Vector{SNNFloat} = zeros(N)
    spike_raster::Vector{SNNInt} = zeros(N)
    records::Dict = Dict()
end

function integrate!(p::AD, param::ADEXParameter, dt::SNNFloat)
    @unpack N, cnt, v, w, fire, I,spike_raster = p
    @unpack a,b,cm,v_rest,tau_m,tau_w,v_thresh,delta_T,v_spike,v_reset,spike_delta = param
    if spike_raster[cnt-1] == 1 || fire[1]
      v[1] = v_reset
      w[1] += b
    end
    dv  = (((v_rest-v[1]) +
            delta_T*exp((v[1] - v_thresh)/delta_T))/tau_m +
            (I[1] - w[1])/cm) *dt
    v[1] += dv
    w[1] += dt * (a*(v[1] - v_rest) - w[1])/tau_w * dt


    fire[1] = v[1] > v_thresh

    if v[1]>v_thresh
        fire[1] = 1 # v[1] > vPeak
        v[1] = spike_delta
        spike_raster[cnt] = 1

    else
        spike_raster[cnt] = 0
    end

    cnt+=1
end
