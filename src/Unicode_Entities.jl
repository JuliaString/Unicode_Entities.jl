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

struct PackedEntities{S,T} <: AbstractPackedTable{String}
    offsetvec::Vector{T}
    namtab::Vector{S}
end
PackedEntities(tab::PackedTable) = PackedEntities(tab.offsetvec, tab.namtab)

VER = UInt32(1)

struct Unicode_Table{S,T,V}
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

struct Unicode_Entity <: AbstractEntityTable
    tab::Unicode_Table
    nam::PackedEntities
end

function Base.getindex(ent::Unicode_Entity, ind::Integer)
    str = ent.nam
    _unpackword(str.namtab[str.offsetvec[ind] + 1 : str.offsetvec[ind+1]],
                ent.tab.wrd1, ent.tab.wrd2)
end

function __init__()
    tab = Unicode_Table(StrTables.load(joinpath(Pkg.dir("Unicode_Entities"),
                                                "data", "unicode.dat"))...)
    nam = PackedEntities(tab.nam)
    global default = Unicode_Entity(tab, nam)
end

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
    String(take!(io))
end

## Override methods

StrTables._get_table(ent::Unicode_Entity) = ent.tab
StrTables._get_names(ent::Unicode_Entity) = ent

function StrTables._get_str(ent::Unicode_Entity, ind)
    tab = ent.tab
    string(Char(ind <= tab.base32 ? tab.val16[ind] : tab.val32[ind - tab.base32] + 0x10000))
end

function StrTables.lookupname(ent::Unicode_Entity, str::AbstractString)
    rng = searchsorted(ent.nam, uppercase(str))
    isempty(rng) ? StrTables._empty_str : _get_str(ent.tab, ent.tab.ind[rng.start])
end

StrTables.matches(ent::Unicode_Entity, vec::Vector{T}) where {T} =
    length(vec) == 1 ? matchchar(ent, vec[1]) : StrTables._empty_str_vec

StrTables.longestmatches(ent::Unicode_Entity, vec::Vector{T}) where {T} =
    isempty(vec) ? StrTables._empty_str_vec : matchchar(ent, uppercase(vec[1]))

function StrTables.completions(ent::Unicode_Entity, str)
    up = uppercase(str)
    [nam for nam in ent.nam if startswith(nam, up)]
end

end # module Unicode_Entities
