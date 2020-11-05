# Unicode_Entities: Support for using Unicode entity names for characters

[pkg-url]: https://github.com/JuliaString/Unicode_Entities.jl.git

[julia-url]:    https://github.com/JuliaLang/Julia
[julia-release]:https://img.shields.io/github/release/JuliaLang/julia.svg

[release]:      https://img.shields.io/github/release/JuliaString/Unicode_Entities.jl.svg
[release-date]: https://img.shields.io/github/release-date/JuliaString/Unicode_Entities.jl.svg

[license-img]:  http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat
[license-url]:  LICENSE.md

[gitter-img]:   https://badges.gitter.im/Join%20Chat.svg
[gitter-url]:   https://gitter.im/JuliaString/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

[travis-url]:   https://travis-ci.org/JuliaString/Unicode_Entities.jl
[travis-s-img]: https://travis-ci.org/JuliaString/Unicode_Entities.jl.svg
[travis-m-img]: https://travis-ci.org/JuliaString/Unicode_Entities.jl.svg?branch=master

[codecov-url]:  https://codecov.io/gh/JuliaString/Unicode_Entities.jl
[codecov-img]:  https://codecov.io/gh/JuliaString/Unicode_Entities.jl/branch/master/graph/badge.svg

[contrib]:    https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat

[![][release]][pkg-url] [![][release-date]][pkg-url] [![][license-img]][license-url] [![contributions welcome][contrib]](https://github.com/JuliaString/Unicode_Entities.jl/issues)

| **Julia Version** | **Unit Tests** | **Coverage** |
|:------------------:|:------------------:|:---------------------:|
| [![][julia-release]][julia-url] | [![][travis-s-img]][travis-url] | [![][codecov-img]][codecov-url]
| Julia Latest | [![][travis-m-img]][travis-url] | [![][codecov-img]][codecov-url]

Unicode_Entities.jl
====================================================================

This builds tables for looking up Unicode entity names and returning the Unicode character(s),
looking up a character or pair of characters and finding Unicode entity names that return it/them,
and finding all of the Unicode name completions for a particular string, if any.

Version 1.1.x has is based on Unicode version 13.0.0
