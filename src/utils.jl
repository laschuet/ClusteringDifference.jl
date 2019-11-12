"""
    sub(A::Matrix{Ta}, B::Matrix{Tb}) where {Ta<:Real,Tb<:Real}
    ⊟(A::Matrix{Ta}, B::Matrix{Tb}) where {Ta<:Real,Tb<:Real}

Subtract matrices of possibly different dimensions.
"""
function sub(A::Matrix{Ta}, B::Matrix{Tb}) where {Ta<:Real,Tb<:Real}
    sza = size(A)
    szb = size(B)
    sza == szb && return A - B
    x, y = max.(sza, szb)
    A2 = Matrix{Union{Nothing,Ta}}(nothing, x, y)
    B2 = Matrix{Union{Nothing,Tb}}(nothing, x, y)
    A2[1:sza[1], 1:sza[2]] = A
    B2[1:szb[1], 1:szb[2]] = B
    T = promote_type(eltype(Ta), eltype(Tb))
    S = Matrix{Union{Nothing,T}}(undef, x, y)
    map!((a, b) -> begin
        isnothing(a) && return b
        isnothing(b) && return a
        return a - b
    end, S, A2, B2)
    return S
end

"""
"""
function diff(A::Matrix, B::Matrix, I::Vector, J::Vector)
    sza = size(A)
    szb = size(B)
end

"""
    diff(a::Vector, b::Vector)

Compute the difference between the vectors `a` and `b`.
"""
function Base.diff(a::Vector, b::Vector)
    ab = union(a, b)
    removed = -1 * setdiff(ab, a)
    added = setdiff(ab, b)
    result = [removed; added]
    sort!(result, by=abs)
    return result
end
