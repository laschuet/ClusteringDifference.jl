abstract type ClusteringDifference end

"""
    PartitionalClusteringDifference

Difference between two partitional clustering models.
"""
struct PartitionalClusteringDifference <: ClusteringDifference
    size::Tuple{Int64, Int64}
    X::Matrix{Any}
    #C::Matrix{Int}
    #W::Matrix{Float64}
    Y::Vector{Int}
    μ::Vector{Any}
end

# Partitional clustering model subtraction
function Base.:-(a::PartitionalClustering, b::PartitionalClustering)
    # TODO: Avoid assumption that sizes are equal
    sz = size(a.X) .- size(b.X)
    X = a.X - b.X
    #C = a.C - b.C
    #W = a.W - b.W
    Y = a.Y - b.Y
    μ = a.μ - b.μ
    return PartitionalClusteringDifference(sz, X, Y, μ)
end

"""
    forward(clusterings, i)
    Δ(clusterings, i)

Compute the forward difference of the clustering model at the given `i`.
"""
function forward(clusterings::Vector{PartitionalClustering}, i::Integer)
    i == length(clusterings) && return nothing
    return clusterings[i + 1] - clusterings[i]
end
const Δ = forward

"""
    backward(clusterings, i)
    ∇(clusterings, i)

Compute the backward difference of the clustering model at the given `i`.
"""
function backward(clusterings::Vector{PartitionalClustering}, i::Integer)
    i == 1 && return clusterings[1]
    return clusterings[i] - clusterings[i - 1]
end
const ∇ = backward