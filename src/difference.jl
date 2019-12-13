"""
    AbstractClusteringDifference

Supertype for clustering differences.
"""
abstract type AbstractClusteringDifference end

"""
    PartitionalClusteringDifference{Tx<:Union{Nothing,Real},Tc<:Union{Nothing,Integer},Tw<:Union{Nothing,Real},
                                    Ty<:Union{Nothing,Real},Tm<:Union{Nothing,Real}} <: AbstractClusteringDifference

Difference between two partitional clusterings.
"""
struct PartitionalClusteringDifference{Tx<:Union{Nothing,Real},Tc<:Union{Nothing,Integer},Tw<:Union{Nothing,Real},
                                    Ty<:Union{Nothing,Real},Tm<:Union{Nothing,Real}} <: AbstractClusteringDifference
    X::MatrixDifference{Tx}
    i::NTuple{3,Vector{Int}}
    j::NTuple{3,Vector{Int}}
    C::MatrixDifference{Tc}
    W::MatrixDifference{Tw}
    Y::MatrixDifference{Ty}
    M::MatrixDifference{Tm}
    m::Int
    n::Int
    k::Int

    function PartitionalClusteringDifference{Tx,Tc,Tw,Ty,Tm}(X::MatrixDifference{Tx},
                                                            i::NTuple{3,Vector{<:Integer}},
                                                            j::NTuple{3,Vector{<:Integer}},
                                                            C::MatrixDifference{Tc},
                                                            W::MatrixDifference{Tw},
                                                            Y::MatrixDifference{Ty},
                                                            M::MatrixDifference{Tm},
                                                            m::Integer,
                                                            n::Integer,
                                                            k::Integer) where {Tx<:Union{Nothing,Real},
                                                                            Tc<:Union{Nothing,Integer},
                                                                            Tw<:Union{Nothing,Real},
                                                                            Ty<:Union{Nothing,Real},
                                                                            Tm<:Union{Nothing,Real}}
        nc = size(C, 2)
        nw = size(W, 2)
        nc == nw || throw(DimensionMismatch("dimensions of constraints and weights must match"))
        return new(X, i, j, C, W, Y, M, m, n, k)
    end
end
PartitionalClusteringDifference(X::MatrixDifference{Tx},
                                i::NTuple{2,Vector{Ti}},
                                j::NTuple{2,Vector{Tj}},
                                C::MatrixDifference{Tc},
                                W::MatrixDifference{Tw},
                                Y::MatrixDifference{Ty},
                                M::MatrixDifference{Tm}, m::Integer, n::Integer,
                                k::Integer) where {Tx,Ti,Tj,Tc,Tw,Ty,Tm} =
    PartitionalClusteringDifference{Tx,Tc,Tw,Ty,Tm}(X, i, j, C, W, Y, M, m, n, k)

function PartitionalClusteringDifference(X::MatrixDifference{Tx},
                                        C::MatrixDifference{Tc},
                                        W::MatrixDifference{Tw},
                                        Y::MatrixDifference{Ty},
                                        M::MatrixDifference{Tm},
                                        m::Integer, n::Integer, k::Integer) where {Tx,Tc,Tw,Ty,Tm}
    i = Int[], Int[], Int[]
    j = Int[], Int[], Int[]
    return PartitionalClusteringDifference(X, i, j, C, W, Y, M, m, n, k)
end

# Partitional clustering difference equality operator
==(a::PartitionalClusteringDifference,
        b:: PartitionalClusteringDifference) =
    (a.X == b.X && a.i == b.i && a.j == b.j && a.C == b.C && a.W == b.W
            && a.Y == b.Y && a.M == b.M && a.m == b.m && a.n == b.n
            && a.k == b.k)

# Compute hash code
hash(a::PartitionalClusteringDifference, h::UInt) =
    hash(a.X, hash(a.i, hash(a.j, hash(a.C, hash(a.W, hash(a.Y, hash(a.M,
        hash(a.m, hash(a.n, hash(a.k,
            hash(:PartitionalClusteringDifference, h)))))))))))

# Partitional clustering subtraction operator
function -(a::PartitionalClustering, b::PartitionalClustering)
    X = diff(a.X, b.X, a.i, a.j, b.i, b.j)
    i = diff(a.i, b.i)
    j = diff(a.j, b.j)
    C = diff(a.C, b.C, a.j, a.j, b.j, b.j)
    W = diff(a.W, b.W, a.j, a.j, b.j, b.j)
    Y = diff(a.Y, b.Y, 1:size(a.Y, 1), a.j, 1:size(b.Y, 1), b.j)
    M = diff(a.M, b.M, a.i, 1:size(a.M, 2), b.i, 1:size(b.M, 2))
    m, n = size(a.X) .- size(b.X)
    k = size(a.M, 2) - size(b.M, 2)
    return PartitionalClusteringDifference(X, i, j, C, W, Y, M, m, n, k)
end

"""
    forwarddiff(a::AbstractVector{<:AbstractClustering}, i::Int[, h::Int=1])

Compute the forward difference of the clustering at index `i` with step
size `h`.
"""
function forwarddiff(a::AbstractVector{<:AbstractClustering}, i::Int, h::Int=1)
    i > length(a) - h && return nothing
    return a[i + h] - a[i]
end

"""
    backwarddiff(a::AbstractVector{<:AbstractClustering}, i::Int[, h::Int=1])

Compute the backward difference of the clustering at index `i` with step
size `h`.
"""
function backwarddiff(a::AbstractVector{<:AbstractClustering}, i::Int, h::Int=1)
    if i - h < 1
        c = a[i]
        m, n = size(c.X)
        k = size(c.M, 2)
        return PartitionalClusteringDifference(c.X, c.i, c.j, c.C, c.W, c.Y,
                c.M, m, n, k)
    end
    return a[i] - a[i - h]
end
