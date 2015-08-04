using JLD2

type TestType1
    x::Int
end
type TestType2
    x::Int
end
immutable TestType3
    x::TestType2
end

type TestType4
    x::Int
end
type TestType5
    x::TestType4
end
type TestType6 end
bitstype 8 TestType7
immutable TestType8
    a::TestType4
    b::TestType5
    c::TestType6
    d::TestType7
end
immutable TestTypeContainer{T}
    a::T
    b::Int
end
bitstype 16 TestType9
immutable TestType10
    a::Int
    b::UInt8
end
immutable TestType11
    a::Int
    b::UInt8
end
immutable TestType12
    x::ASCIIString
end
type TestType13
    a
    TestType13() = new()
end
immutable TestType14{T}
    x::T
    y::Int
end
immutable TestType15{T,S}
    x::T
    y::S
end
immutable TestType16{T}
    x::T
    y::Int
end
immutable TestTypeContainer2{T}
    a::T
    b::Int
end
immutable TestTypeContainer3{T,S}
    a::T
    b::S
end
immutable TestTypeContainer4{T}
    a::T
    b::Int
end
immutable TestTypeContainer5{T,S}
    a::T
    b::S
end
immutable TestType17
    x::Int
end

fn = joinpath(tempdir(),"test.jld")
file = jldopen(fn, "w")
write(file, "x1", TestType1(57))
write(file, "x2", TestType3(TestType2(1)))
write(file, "x3", TestType4(1))
write(file, "x4", TestType5(TestType4(2)))
write(file, "x5", [TestType5(TestType4(i)) for i = 1:5])
write(file, "x6", TestType6())
write(file, "x7", reinterpret(TestType7, 0x77))
write(file, "x8", TestType8(TestType4(2), TestType5(TestType4(3)),
                            TestType6(), reinterpret(TestType7, 0x12)))
write(file, "x9", (TestType4(1),
                   (TestType5(TestType4(2)),
                    [TestType5(TestType4(i)) for i = 1:5]),
                   TestType6()))
write(file, "x10", TestTypeContainer(TestType4(3), 4))
write(file, "x11", reinterpret(TestType9, 0x1234))
write(file, "x12", TestType10(1234, 0x56))
write(file, "x13", TestType11(78910, 0x11))
write(file, "x14", TestType12("abcdefg"))
write(file, "x15", TestType13())
write(file, "x16", TestType14(1.2345, 67))
write(file, "x17", TestType15(8.91011, 12))
write(file, "x18", TestType16(12.131415, 1617))
write(file, "x19", TestTypeContainer2(TestType4(3), 4))
write(file, "x20", TestTypeContainer3(TestType4(3), 4))
write(file, "x21", TestTypeContainer4(TestType4(3), 4))
write(file, "x22", TestTypeContainer5(TestType4(3), 4))
write(file, "x23", TestType17(5678910))

close(file)

workspace()
using LastMain.JLD2, Base.Test
type TestType1
    x::Float64
end
type TestType2
    x::Int
end
immutable TestType3
    x::TestType1
end
immutable TestTypeContainer{T}
    a::T
    b::Int
end
bitstype 8 TestType9
immutable TestType10
    a::Int
    b::UInt8
    c::UInt8
end
immutable TestType11
    b::UInt8
end
immutable TestType12
    x::Int
end
type TestType13
    a
end
immutable TestType14{T,S}
    x::T
    y::S
end
immutable TestType15{T}
    x::T
    y::Float64
end
immutable TestType16{T<:Integer}
    x::T
    y::Int
end
immutable TestTypeContainer2{T}
    a::T
    b::ASCIIString
end
immutable TestTypeContainer3{T,S}
    a::T
    b::S
end
immutable TestTypeContainer4{T,S}
    a::T
    b::S
end
immutable TestTypeContainer5{T}
    a::T
    b::Int
end
const TestType17 = 5

file = jldopen(LastMain.fn, "r")
x = read(file, "x1")
@test isa(x, TestType1)
@test x.x === 57.0
@test_throws MethodError read(file, "x2")
println("The following missing type warnings are a sign of normal operation.")
@test read(file, "x3").x == 1
@test read(file, "x4").x.x == 2

x = read(file, "x5")
for i = 1:5
    @test x[i].x.x == i
end
@test isempty(fieldnames(typeof(read(file, "x6"))))
@test reinterpret(UInt8, read(file, "x7")) == 0x77

x = read(file, "x8")
@test x.a.x == 2
@test x.b.x.x == 3
@test isempty(fieldnames(typeof(x.c)))
@test reinterpret(UInt8, x.d) == 0x12

x = read(file, "x9")
@test isa(x, Tuple)
@test length(x) == 3
@test x[1].x == 1
@test isa(x[2], Tuple)
@test length(x[2]) == 2
@test x[2][1].x.x == 2
for i = 1:5
    @test x[2][2][i].x.x == i
end
@test isempty(fieldnames(typeof(x[3])))

x = read(file, "x10")
@test isa(x, TestTypeContainer{Any})
@test x.a.x === 3
@test x.b === 4

x = read(file, "x11")
@test !isa(x, TestType9)
@test reinterpret(UInt16, x) === 0x1234

x = read(file, "x12")
@test !isa(x, TestType10)
@test x.a === 1234
@test x.b === 0x56

x = read(file, "x13")
@test isa(x, TestType11)
@test x.b === 0x11

x = read(file, "x14")
@test !isa(x, TestType12)
@test x.x == "abcdefg"

@test_throws JLD2.UndefinedFieldException x = read(file, "x15")

x = read(file, "x16")
@test !isa(x, TestType14)
@test x.x === 1.2345
@test x.y === 67

x = read(file, "x17")
@test !isa(x, TestType15)
@test x.x === 8.91011
@test x.y === 12

x = read(file, "x18")
@test !isa(x, TestType16)
@test x.x === 12.131415
@test x.y === 1617

x = read(file, "x19")
@test !isa(x, TestTypeContainer2)
@test x.a.x === 3
@test x.b === 4

x = read(file, "x20")
@test isa(x, TestTypeContainer3{Any,Int})
@test x.a.x === 3
@test x.b === 4

x = read(file, "x21")
@test !isa(x, TestTypeContainer4)
@test x.a.x === 3
@test x.b === 4

x = read(file, "x22")
@test !isa(x, TestTypeContainer5)
@test x.a.x === 3
@test x.b === 4

x = read(file, "x23")
@test x.x === 5678910

close(file)