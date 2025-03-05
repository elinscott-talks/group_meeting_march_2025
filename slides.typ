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
                                title: [Automated workflows],
                                subtitle: [What I have learned from writing `koopmans`],
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
What I've learned after 5 years of trying to automate Koopmans functionals

== A brief history of the `koopmans` code
#slide()[
#set text(size: 0.8em)
#pause
- I arrived in THEOS in 2019, started learning how to run Koopmans functionals -- and it was painful! #pause
- I was familiar with ASE so wrote some simple scripts #pause
- decided this was something we wanted for everyone #pause
- (and having been advised not to use AiiDA...) #pause
- implemented `kcp.x` support in `ASE` #pause
- implemented a Koopmans ΔSCF workflow for molecules #pause
- DFT, Wannierize, etc -- we want reusable subworkflows #pause
- start to add tests, documentation, etc. and you have `koopmans`
- more recently, massive changes to integrate with `AiiDA` (I'll discuss this later)
#pause
... but what have I learned throughout this process?
]

// #focus-slide(background-img: "abe_simposon")[]

Well not quite, but the intervening years have not been kind!

= Interfacing with AiiDA
== What I needed to do

- isolate into steps
- functional programming
- what is the best way of writing a workflow?

= Common Workflow Language

== Basic Concepts of CWL

#image("cwl/cwl_logo.png", height: 50%)

#pause
- "an open standard for describing how to run command line tools and connect them to create workflows" #pause
- introduced in 2014; version 1.2 released in 2020 #pause
- mostly used by bioinformatics community

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
`echo.cwl`

#raw(read("cwl/hello_world.cwl"), lang: "yaml")

#pagebreak()
  
== ExpressionTool
`uppercase.cwl`

#raw(read("cwl/uppercase.cwl"), lang: "yaml")

== Workflow
`echo_uppercase.cwl`

#raw(read("cwl/echo_uppercase.cwl"), lang: "yaml")

== Pros and Cons

#slide()[
#set text(size: 0.8em)
- pros: #pause
  - explicit #pause
  - composable #pause
  - customisable #pause
- cons: #pause
  - verbose with lots of boilerplate
  - complicated workflows become very complicated CWL (e.g. `while`) #pause
  - `ExpressionTool` restricted to Javascript #pause
  - need to define custom types (see e.g. OPTIMADE, PREMISE) #pause
  - custom types do not permit defaults #pause
  - rigorous schemas require willingness from the community
  
]

== ... willingness from the community?
#image("cwl/qe_issue.png", height: 100%)

#image("cwl/qe_issue_2.png", width: 100%)
// 
// = So where does that leave koopmans?
// == Rewriting `koopmans`
// `koopmans` is slowly being refactored into "CWL-inspired" Python
// 
// #show raw: it => [
//   #set text(size: 0.5em)
//   #it
// ]
// #raw(read("bin2xml.py"), lang: "python")
// 
// == An example composite workflow
// 
// #raw(read("kcw_then_w90.py"), lang: "python")
// 
// = Aside: Common Workflows
// == Common Workflows
// Compare with Common Workflows (all implemented in AiiDA https://doi.org/10.1038/s41524-021-00594-6, but can change code -- maybe talk with Marnik about this and the advantages/limitations. Are people writing any common workflows or is everything still code-dependent? No -- for anything complicated you need code-specific logic)
// 
// = Conclusions
// == 
// In an ideal world:
// - workflows with very prescribed inputs and outputs
// - workflows that are engine-agnostic (we should not have to rewrite how to calculate binding energy curves, defect energies etc again and again -- nor should this knowledge exclusive to AiiDA)
// - should make concatenating workflows straightforward
// - workflow manages such as AiiDA can read and run .cwl files
// 
// The alternative: siloed communities where we only write AiiDA -- that is valid, but we need to simplify, we need to educate, we need to commit (and not push people away from it)
// 
// Where we call down
// - everyone wants bespoke

== References

#bibliography("references.bib")
