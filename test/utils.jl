@testset "utils" begin
    @testset "set difference" begin
        a = SetDifference([1], [2, 3], [4, 5])
        b = SetDifference([1], [2, 3], [4, 5])
        c = SetDifference([1], [2, 3], [4, 5])

        @test isa(a, SetDifference)
        @test a.comval == [1] && a.addval == [2, 3] && a.remval == [4, 5]

        @test a == a
        @test a == b && b == a
        @test a == b && b == c && a == c

        @test hash(a) == hash(a)
        @test a == b && hash(a) == hash(b)

        @test common(a) == [1]
        @test added(a) == [2, 3]
        @test removed(a) == [4, 5]
    end

    @testset "matrix difference" begin
        # TODO Implement tests
    end

    @testset "difference operator" begin
        a = [1, 2, 3, 3]
        b = [4, 2, 1]
        @test diff(a, a) == ([1, 2, 3], [], [])
        @test diff(a, b) == ([1, 2], [4], [3])
        @test diff(b, a) == ([2, 1], [3], [4])

        A = [1 0 1; 0 1 0; 0 0 1]
        B = [1 1 1 1; 1 1 1 1]
        ia = [1, 2, 5]
        ja = [2, 8, 11]
        ib = [1, 8]
        jb = [2, 3, 4, 11]
        @test diff(A, A, ia, ja, ia, ja) == (
            sparse([0 0 0; 0 0 0; 0 0 0]),
            [], [],
            [], []
        )
        @test diff(A, B, ia, ja, ib, jb) == (
            sparse([0 0]),
            [1 1 1 1], [1 1; 1 1],
            [0 1 0; 0 0 1], reshape([0, 1, 0], :, 1)
        )
        @test diff(B, A, ib, jb, ia, ja) == (
            sparse([0 0]),
            [0 1 0; 0 0 1], reshape([0, 1, 0], :, 1),
            [1 1 1 1], [1 1; 1 1]
        )
        @test diff(A, A) == (
            sparse([0 0 0; 0 0 0; 0 0 0]),
            [], [],
            [], []
        )
        @test diff(A, B) == (
            sparse([0 -1 0; -1 0 -1]),
            [], reshape([1, 1], :, 1),
            [0 0 1], []
        )
        @test diff(B, A) == (
            sparse([0 1 0; 1 0 1]),
            [0 0 1], [],
            [], reshape([1, 1], :, 1)
        )
    end
end
