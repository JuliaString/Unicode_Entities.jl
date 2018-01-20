using Unicode_Entities

@static VERSION < v"0.7.0-DEV" ? (using Base.Test) : (using Test)

# Test the functions lookupname, matches, longestmatches, completions
# Check that characters from all 3 tables (BMP, non-BMP, 2 character) are tested

UE = Unicode_Entities

const datapath = joinpath(Pkg.dir(), "Unicode_Entities", "data")
const dpath = "ftp://ftp.unicode.org/Public/UNIDATA/"
const fname = "UnicodeData.txt"

const symnam = Vector{String}()
const symval = Vector{Char}()

"""Load up all names and characters from original data file"""
function load_unicode_data()
    lname = joinpath(datapath, fname)
    isfile(lname) || download(string(dpath, fname), lname)
    aliasnam = Vector{String}()
    aliasval = Vector{Char}()
    open(lname, "r") do f
        while (l = chomp(readline(f))) != ""
            flds = split(l, ";")
            str = flds[2]
            alias = flds[11]
            ch = Char(parse(UInt32, flds[1], 16))
            if str[1] == '<'
                str != "<control>" && continue
                str = ""
            end
            if str != ""
                push!(symnam, str)
                push!(symval, ch)
            end
            if alias != ""
                push!(aliasnam, alias)
                push!(aliasval, ch)
            end
        end
    end
    # Check for duplicates
    names = Set{String}(symnam)
    for (str,ch) in zip(aliasnam, aliasval)
        if !(str in names)
            push!(symnam, str)
            push!(symval, ch)
        end
    end
end

load_unicode_data()
uln = UE.lookupname
umc = UE.matchchar

@testset "Unicode_Entities" begin

    @testset "matches data file" begin
        for (i, ch) in enumerate(symval)
            list = umc(ch)
            if !isempty(list)
                @test symnam[i] in list
            end
        end
        for (i, nam) in enumerate(symnam)
            str = uln(nam)
            if str != ""
                @test symval[i] == str[1]
            end
        end
    end
        
@testset "lookupname" begin
    @test UE.lookupname("foobar")   == ""
    @test UE.lookupname(SubString("My name is Spock", 12)) == ""
    @test UE.lookupname("end of text") == "\x03" # \3
    @test UE.lookupname("TIBETAN LETTER -A") == "\u0f60"
    @test UE.lookupname("LESS-THAN OR SLANTED EQUAL TO") == "\u2a7d"
    @test UE.lookupname("REVERSED HAND WITH MIDDLE FINGER EXTENDED") == "\U1f595"
end

@testset "matches" begin
    @test isempty(UE.matches(""))
    @test isempty(UE.matches("\uf900"))
    @test isempty(UE.matches(SubString("This is \uf900", 9)))
    for (chrs, exp) in (("\U1f596", ["RAISED HAND WITH PART BETWEEN MIDDLE AND RING FINGERS"]),
                        ("\u0f4a", ["TIBETAN LETTER REVERSED TA"]),
                        (".", ["FULL STOP", "PERIOD"]))
        res = UE.matches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "longestmatches" begin
    @test isempty(UE.longestmatches("\uf900 abcd"))
    @test isempty(UE.longestmatches(SubString("This is \uf900 abcd", 9)))
    for (chrs, exp) in (("\U1f596 abcd", ["RAISED HAND WITH PART BETWEEN MIDDLE AND RING FINGERS"]),
                        (".abcd", ["FULL STOP", "PERIOD"]),
                        ("\u0f4a#123", ["TIBETAN LETTER REVERSED TA", "TIBETAN LETTER TTA"]))
        res = UE.longestmatches(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end

@testset "completions" begin
    @test isempty(UE.completions("ScottPaulJones"))
    @test isempty(UE.completions(SubString("My name is Scott", 12)))
    for (chrs, exp) in (("ZERO", ["ZERO WIDTH JOINER", "ZERO WIDTH NO-BREAK SPACE",
                                  "ZERO WIDTH NON-JOINER", "ZERO WIDTH SPACE"]),
                        ("BACK OF", ["BACK OF ENVELOPE"]))
        res = UE.completions(chrs)
        @test length(res) >= length(exp)
        @test intersect(res, exp) == exp
    end
end
end

