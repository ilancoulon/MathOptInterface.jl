function MOI.writeproblem(m::MOFFile, io::IO, indent::Int=0)
    if indent > 0
        write(io, JSON.json(m.d, indent))
    else
        write(io, JSON.json(m.d))
    end
end
function MOI.writeproblem(m::MOFFile, f::String, indent::Int=0)
    open(f, "w") do io
        MOI.writeproblem(m, io, indent)
    end
end

function MOI.addvariable!(m::MOFFile, name::String="")
    i = length(m["variables"]) + 1
    v = MOI.VariableReference(i)
    if name == ""
        push!(m["variables"], "x$(i)")
    else
        push!(m["variables"], name)
    end
    m.ext[v] = i
    v
end
MOI.addvariables!(m::MOFFile, n::Int, names::Vector{String}=fill("", n)) = [MOI.addvariable!(m, names[i]) for i in 1:n]

"""
    rename!(m::MOFFile, v::MOI.VariableReference, name::String)

Rename the variable `v` in the MOFFile `m` to `name`. This should be done
immediately after introducing a variable and before it is used in any constraints.

If the variable has already been used, this function will _not_ update the
previous references.
"""
function rename!(m::MOFFile, v::MOI.VariableReference, name::String)
    i = m.ext[v]
    m["variables"][i] = name
end

function MOI.setobjective!(m::MOFFile, sense::MOI.OptimizationSense, func::MOI.AbstractFunction)
    m["sense"] = Object(sense)
    m["objective"] = Object!(m, func)
end

function MOI.addconstraint!(m::MOFFile, func::MOI.AbstractFunction, set::MOI.AbstractSet, name::String="")
    if name == ""
        ci = length(m["constraints"])
        name = "c$(ci + 1)"
    end
    push!(m["constraints"],
        Object(
            "name"     => name,
            "set"      => Object(set),
            "function" =>  Object!(m, func)
        )
    )
end

function Object(sense::MOI.OptimizationSense)
    if sense == MOI.MaxSense
        return "max"
    elseif sense == MOI.MinSense
        return "min"
    end
    error("Sense $(sense) not recognised.")
end
