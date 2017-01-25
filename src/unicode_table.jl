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
