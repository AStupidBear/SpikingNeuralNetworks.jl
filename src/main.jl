function sim!(P, C, dt)
    integrate!(P[1], P[1].param, SNNFloat(dt))
    record!(P[1])
    #for c in C
    #    forward!(c, c.param)
    #    record!(c)
    #end
end

function sim!(P, C; dt = 0.25ms, simulation_duration = 1300ms, delay = 300ms,stimulus_duration=1000ms)

    temp = deepcopy(P[1].I)
    cnt = 0
    for t = 0ms:dt:simulation_duration
        cnt+=1
    end
    size = simulation_duration/dt

    cnt1 = 0
    for t = 0ms:dt:simulation_duration
        cnt1+=1
        #@show(cnt1)
        if cnt1 < delay/dt 
           #3*size/4 # if cnt1 > delay
           P[1].I[1] = 0.0 
        end 
        if cnt1 > (delay/dt + stimulus_duration/dt)
	   P[1].I[1] = 0.0 
           #convert(Array{Float32,1},0.0)
        end 
        if (delay/dt) < cnt1 < (stimulus_duration/dt)  
           P[1].I[1] = maximum(temp[1])
        end
        sim!(P, C, dt)

    end
    #delta = stimulus_duration-delay

end


#=

function sim!(P, C, dt)
    for p in P
        integrate!(p, p.param, SNNFloat(dt))
        record!(p)
    end
    for c in C
        forward!(c, c.param)
        record!(c)
    end
end

function sim!(P, C; dt = 0.1ms, duration = 10ms)
    for t = 0ms:dt:duration
        sim!(P, C, dt)
    end
end
=#
function train!(P, C, dt, t = 0)
    for p in P
        integrate!(p, p.param, SNNFloat(dt))
        record!(p)
    end
    for c in C
        forward!(c, c.param)
        plasticity!(c, c.param, SNNFloat(dt), SNNFloat(t))
        record!(c)
    end
end

function train!(P, C; dt = 0.1ms, duration = 10ms)
    for t = 0ms:dt:duration
        train!(P, C, SNNFloat(dt), SNNFloat(t))
    end
end
