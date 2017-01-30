# License is MIT: https://github.com/JuliaString/Unicode_Entities/LICENSE.md

__precompile__()

"""
# Public API (nothing is exported)

* lookupname(str)
* matchchar(char)
* matches(str)
* longestmatches(str)
* completions(str)
"""
module Unicode_Entities

using StrTables

immutable PackedEntities{S,T} <: AbstractPackedTable{String}
    offsetvec::Vector{T}
    namtab::Vector{S}
end
PackedEntities(tab::PackedTable) = PackedEntities(tab.offsetvec, tab.namtab)
Base.getindex(str::PackedEntities, ind::Integer) =
    _unpackword(str.namtab[str.offsetvec[ind]+1:str.offsetvec[ind+1]])

VER = UInt32(1)

immutable Unicode_Table{S,T,V} <: AbstractEntityTable
    ver::UInt32
    tim::String
    inf::String
    base32::UInt32
    nam::PackedTable{S,V}	# This has packed byte vectors
    ind::Vector{UInt16}
    wrd1::StrTable{T}           # This has sorted words for 1-byte
    wrd2::StrTable{T}           # This has sorted words for 2-byte
    val16::Vector{UInt16}
    ind16::Vector{UInt16}
    val32::Vector{UInt16}
    ind32::Vector{UInt16}
end

function __init__()
    const global _tab =
        Unicode_Table(StrTables.load(joinpath(Pkg.dir("Unicode_Entities"), "data", "unicode.dat"))...)
    const global _names = PackedEntities(_tab.nam)
end

const _empty_str = ""
const _empty_str_vec = Vector{String}()

"""
Internal function to unpack the packed Unicode entity names

Unicode has a very limited character set for the entity names, 0-9, A-Z, -, (, and ).
( and ) are only used for 4 names, so those are special cased to store in the word table.

0 represents a space, when needed between characters
1 represents a hyphen
2-11 represents the digits 0-9
12-37 represents the letters A-Z
38-53 represents up to 16*256 words stored in the wrd2 table
54-255 represent 202 words stored in the wrd1 table
"""
_unpackword(v::Vector{UInt8}) = _unpackword(v, _tab.wrd1, _tab.wrd2)
function _unpackword(v::Vector{UInt8}, w1, w2)
    io = IOBuffer()
    pos = 0
    len = length(v)
    prevw = false
    while (pos += 1) <= len
        ch = v[pos]
        if ch < 0x26 # single character (space, hyphen, 0-9, A-Z)
            if ch == 0x00
                write(io, ' ')
            elseif ch == 0x01
                write(io, '-')
            else
                pos != 1 && prevw && write(io, ' ')
                write(io, ch + (ch < 0x0c ? 0x2e : 0x35))
            end
            prevw = false
        else
            pos != 1 && (prevw || v[pos-1]>0x1) && write(io, ' ')
            if ch < 0x36
                write(io, w2[((ch - 0x25)%UInt16<<8 | v[pos+=1])-255])
            else
                write(io, w1[ch - 0x35])
            end
            prevw = true
        end
    end
    @static VERSION < v"0.6-" ? takebuf_string(io) : String(take!(io))
end

_get_str(ind) =
    string(Char(ind <= _tab.base32 ? _tab.val16[ind] : _tab.val32[ind - _tab.base32] + 0x10000))
    
function _get_strings{T}(val::T, tab::Vector{T}, ind::Vector{UInt16})
    rng = searchsorted(tab, val)
    isempty(rng) && return _empty_str_vec
    _names[ind[rng]]
end

function lookupname(str::AbstractString)
    rng = searchsorted(_names, uppercase(str))
    isempty(rng) ? _empty_str : _get_str(_tab.ind[rng.start])
end

matchchar(ch::Char) =
    (ch <= '\uffff'
     ? _get_strings(ch%UInt16, _tab.val16, _tab.ind16)
     : (ch <= '\U1ffff' ? _get_strings(ch%UInt16, _tab.val32, _tab.ind32) : _empty_str_vec))

matches(str::AbstractString) = matches(convert(Vector{Char}, str))
matches(vec::Vector{Char}) = length(vec) == 1 ? matchchar(vec[1]) : _empty_str_vec

longestmatches(str::AbstractString) = longestmatches(convert(Vector{Char},str))
longestmatches(vec::Vector{Char}) = isempty(vec) ? _empty_str_vec : matchchar(uppercase(vec[1]))

completions(str::AbstractString) = completions(String(str))
function completions(str::String)
    str = uppercase(str)
    [nam for nam in _names if startswith(nam, str)]
end

end # module
