# docs/make.jl

using Documenter
using ItemResponseTheory

makedocs(
    sitename = "ItemResponseTheory.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://allen19970828.github.io/ItemResponseTheory.jl",
        assets = String[],
    ),
    modules = [ItemResponseTheory],
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md",
        "Developer Guide" => "developer.md",
    ]
)

deploydocs(
    repo = "github.com/allen19970828/ItemResponseTheory.jl.git",
    devbranch = "main",
)
