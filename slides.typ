#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.1.4": *
#import "@preview/xarrow:0.3.0": xarrow
#import "@preview/cetz:0.3.3"
#import "psi-slides-0.6.1.typ": *
// #import "psi-slides.typ"

// color-scheme can be navy-red, blue-green, or pink-yellow
// #let s = psi-slides.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")
#show: psi-theme.with(aspect-ratio: "16-9",
                      color-scheme: "pink-yellow",
                             config-info(
                                title: [Writing workflows],
                                subtitle: [An outsider's perspective],
                                author: [Edward Linscott],
                                date: datetime(year: 2025, month: 3, day: 12),
                                location: [LMS Seminar],
                                references: [references.bib],
                             ))

// #let s = (s.methods.info)(
//   self: s,
//   title: [Title],
//   subtitle: [Subtitle],
//   author: [Edward Linscott],
//   date: datetime(year: 2024, month: 1, day: 1),
//   location: [Location],
//   references: [references.bib],
// )
// #let blcite(reference) = {
//   text(fill: white, cite(reference))
// }
// 
#set footnote.entry(clearance: 0em)
#show bibliography: set text(0.6em)
// 
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
// #let (init, slides) = utils.methods(s)
// #show: init
// 
// #let (slide, empty-slide, title-slide, new-section-slide, focus-slide, matrix-slide) = utils.slides(s)
// #show: slides

#title-slide()

== Outline
#image("abe_simpson.jpg")
What I've learned after 5 years of trying to automate Koopmans functionals
https://knowyourmeme.com/memes/abe-simpson-talking-to-kids

Well not quite --- but the intervening years have not been kind -- see permit photos)

== History of koopmans
- I want to run Koopmans functional calculations and I know how to write python and use ASE (and I was advised not to use AiiDA...)
- atoms
- calculators
- where necessary, use outputs of previous calculation into subsequent calculation (e.g. link a file, set a parameter etc.)
- start writing multiple scripts
- wannierisation
- dscf
- dfpt
- natural emergence of the idea of a workflow and subworkflows that I want to be able to reuse
...
koopmans

== Interfacing with AiiDA

What I needed to do
- isolate into steps
- functional programming

= Common Workflow Language


== 

#image("cwl/cwl_logo.png", height: 50%)

#pause
- "an open standard for describing how to run command line tools and connect them to create workflows" #pause
- introduced in 2014; version 1.2 released in 2020 #pause
- mostly used by bioinformatics community


== Basic Concepts
#slide(self => [
  #cetz-canvas({
    import cetz.draw: *

    set-style(content: (frame: "rect", stroke: none, padding: 0.5em))

    content((-1.5, 4), "Process", name: "p")
    (pause,)

    content((-12, 0), "CommandLineTool", name: "c")
    line("c", "p")
    (pause,)

    content((-4, 0), "ExpressionTool", name: "e")
    line("e", "p")
    (pause,)
    
    content((3, 0), "Operation", name: "o")
    line("o", "p")
    (pause,)
    
    content((9, 0), "Workflow", name: "w")
    line("w", "p")
  })


])

== CommandLineTool
#show raw: it => [
  #set text(size: 0.8em)
  #it
]
`echo.cwl`

#raw(read("cwl/hello_world.cwl"), lang: "yaml")

== ExpressionTool
`uppercase.cwl`

#raw(read("cwl/uppercase.cwl"), lang: "yaml")

== Workflow
`echo_uppercase.cwl`

#raw(read("cwl/echo_uppercase.cwl"), lang: "yaml")

== Pros and Cons
#show raw: it => [
  #set text(size: 1.25em)
  #it
]

- pros: #pause
  - clear and explicit #pause
  - composable and customisable #pause
- cons: #pause
  - verbose #pause
  - complicated workflows lead to very complicated CWL (e.g. `while`) #pause
  - `ExpressionTool` restricted to Javascript #pause
  - need to define custom types (e.g. OPTIMADE, PREMISE) #pause
  - custom types do not permit defaults #pause
  - rigorous schemas require willingness from the community #pause

==
#image("cwl/qe_issue.png", width: 100%)
==
#image("cwl/qe_issue_2.png", width: 100%)


= So where does that leave koopmans?
== Rewriting `koopmans`
`koopmans` is slowly being refactored into "CWL-inspired" python

#show raw: it => [
  #set text(size: 0.5em)
  #it
]
#raw(read("bin2xml.py"), lang: "python")


= Aside: Common Workflows
== Common Workflows
Compare with Common Workflows (all implemented in AiiDA https://doi.org/10.1038/s41524-021-00594-6, but can change code -- maybe talk with Marnik about this and the advantages/limitations. Are people writing any common workflows or is everything still code-dependent? No -- for anything complicated you need code-specific logic)

In an ideal world:
- workflows with very prescribed inputs and outputs
- workflows that are engine-agnostic (we should not have to rewrite how to calculate binding energy curves, defect energies etc again and again -- nor should this knowledge exclusive to AiiDA)
- should make concatenating workflows straightforward
- workflow manages such as AiiDA can read and run .cwl files

The alternative: siloed communities where we only write AiiDA -- that is valid, but we need to simplify, we need to educate, we need to commit (and not push people away from it)

Where we call down
- everyone wants bespoke

==
Test#footnote("This is a footnote")

= Introduction

== Subsection

#par(justify: true)[#lorem(200)]

#focus-slide()[Here is a focus slide presenting a key idea]

#matrix-slide()[
  This is a matrix slide
][
  You can use it to present information side-by-side
][
  with an arbitrary number of rows and columns
]

== Test
More text appears under the same subsection title as earlier

But a new subsection starts a new page.

Now, let's cite a nice paper.@Linscott2023

== References

#bibliography("references.bib")
