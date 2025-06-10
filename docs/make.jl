using Meteograms
using Documenter

DocMeta.setdocmeta!(Meteograms, :DocTestSetup, :(using Meteograms); recursive=true)

makedocs(;
    modules=[Meteograms],
    authors="renilsonlisboa <renilsonlisboajunior@gmail.com> and contributors",
    sitename="Meteograms.jl",
    format=Documenter.HTML(;
        canonical="https://renilsonlisboa.github.io/Meteograms.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/renilsonlisboa/Meteograms.jl",
    devbranch="master",
)
