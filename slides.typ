#import "touying/lib.typ": *
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
                                title: [How to write your workflow],
                                subtitle: [Lessons I learned writing the `koopmans` package],
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

== A brief history of the `koopmans` code
#slide()[
#set text(size: 0.8em)
#pause
- I arrived in THEOS in 2019, started learning how to run Koopmans functionals -- and it was painful! #pause
- I was familiar with `ASE` so wrote some simple scripts #pause
- decided this was something we wanted for everyone #pause
- ... and having been advised not to use `AiiDA` we stuck with the `ASE` approach #pause
- implemented `kcp.x` support in `ASE` #pause
- the first workflow was Koopmans ΔSCF for molecules; others quickly followed #pause
- reusability of workflows as subworkflows became important (e.g. Wannierisation) #pause
- start to add tests, documentation, etc, ... #pause
#align(center, image("media/logos/koopmans_grey_on_transparent.svg", height: 10%)) #pause
- (more recently) substantial changes to integrate with `AiiDA` (I'll discuss this later)
]

#focus-slide()[
... but what have I learned throughout this process?
]

#slide(config: config-page(margin: 0em),)[
  #image("abe_simpson.jpg", width: 100%)
  #v(-11em)
  #pause
  #align(right, text(fill: white, size: 2em, weight: "bold", "... not quite! "))
]

#slide(config: config-page(margin: 2em, header: none),)[
#grid(columns: (1fr, 1fr),
  align: center + horizon,
  gutter: 1em,
  [2019],
  [2024],
  image("permits/2019.png", width: 100%),
  image("permits/2024.png", width: 100%),
)
]

= What I learned when interfacing `koopmans` with `AiiDA`

== Why do we want to integrate with `AiiDA`?

#matrix-slide(alignment: top)[
  #image("media/logos/koopmans_grey_on_transparent.svg", height: 2em)
  Simple by design #pause
  - local execution only #pause
  - serial step execution (even when steps are independent!) #pause
  - direct access to input/output files #pause
  - simple installation #pause
][
  #image("media/logos/aiida.svg", height: 2em)
  Powerful by design #pause
  - remote execution #pause
  - parallel step execution #pause
  - outputs stored in a database #pause
  - installation more involved #pause

  We could really benefit from a lot of these features
]

== Goals
- be able to execute in parallel and remotely with `AiiDA` #pause
- UI should be as similar as possible #pause
- old mode of running `koopmans` should still work #pause
- minimal/no duplication of logic

== Refactoring
#slide(repeat: 4, self => [
  #let (uncover, only, alternatives) = utils.methods(self)
  #set raw(lang: "python", block: true, tab-size: 2)
  A lot of "bad" design in `koopmans` needed refactoring #pause
  - abstraction of many operations e.g.
    #raw(
      "with open(filename, 'r') as f:
        data = f.read()"
      )
    #pause becomes
    #raw("self.engine.read(filename)")
    #pause
  - ... and, more generally, many responsibilities are moved to the `engine` (reading/writing files, running running calculations, checking the status of calculations, loading pseudopotentials, etc.)
])

#slide([
  - making everything more "pure" #pause e.g. removing all reliance on shared directories #pause
    #raw(lang: "python", block: true, "calc_nscf.parameters.outdir = calc_scf.parameters.outdir")

    #pause
    becomes

    #raw(lang: "python", block: true, "calc_nscf.link(calc_scf.parameters.outdir, 'tmp')")
    where
    #raw(lang: "python", block: true, tab-size: 6,
    "def link(self, src, dst):
      self.engine.link(src=src, dst=self/dst)
    ")
])


#focus-slide()[_Note_: none of this refactoring is specific to `AiiDA`!]

== At the `AiiDA` end
#pause
- conversion of calculators from `ASE` to `AiiDA` and back #pause
- `verdi presto` for simplified `AiiDA` setup #pause
- `verdi dump` for dumping `AiiDA` database to a local file structure

#focus-slide()[Writing workflows well is hard... #pause how can it best be done?]

= Common Workflow Language

== Basic Concepts of CWL

#image("cwl/cwl_logo.png", height: 30%)

#pause
- "an open standard for describing how to run command line tools and connect them to create workflows" #pause
- separate `runners` are required to execute the workflows; a CWL workflow only contains the logic of the workflows #pause
- introduced in 2014; version 1.2 released in 2020 #pause
- mostly used by bioinformatics community

#slide(self => [
  #cetz-canvas({
    import cetz.draw: *

    set-style(content: (frame: "rect", stroke: none, padding: 0.5em))

    content((-1.5, 4), `Process`, name: "p")
    (pause,)

    content((-12, 0), `CommandLineTool`, name: "c")
    line("c", "p")
    (pause,)

    content((-4, 0), `ExpressionTool`, name: "e")
    line("e", "p")
    (pause,)
    
    content((3, 0), `Workflow`, name: "w")
    line("w", "p")
    (pause,)
    
    content((9, 0), `Operation`, name: "o")
    line("o", "p")
  })

#pause
Every `Process` has `inputs` and `outputs`

])

== `CommandLineTool`
#set text(size: 0.8em)
`echo.cwl`

#raw(read("cwl/hello_world.cwl"), lang: "yaml")

#pause Called via #raw("$ cwltool echo.cwl", lang: "bash")

#pagebreak()
  
== `ExpressionTool`
`uppercase.cwl`

#raw(read("cwl/uppercase.cwl"), lang: "yaml")

#pause Called via #raw("$ cwltool uppercase.cwl --message='goes to 11'", lang: "bash")

== `Workflow`
`echo_uppercase.cwl`

#raw(read("cwl/echo_uppercase.cwl"), lang: "yaml")

#pause Called via #raw("$ cwltool echo_uppercase.cwl input.json", lang: "bash")

== `Operation`
`p_versus_np.cwl`

#raw(read("cwl/p_versus_np.cwl"), lang: "yaml")

== A less silly `Operation`

`run_pw.cwl`

#raw(read("cwl/run_pw.cwl"), lang: "yaml")

== Pros and Cons

#slide()[
- pros: #pause
  - explicit #pause
  - composable #pause
  - customisable #pause
- cons: #pause
  - verbose; lots of boilerplate #pause
  - complicated workflows are *very* complicated to write in CWL (e.g. `while`) #pause
  - `ExpressionTool` restricted to Javascript #pause
  - need to define custom types (see e.g. OPTIMADE, PREMISE) #pause
  - custom types do not permit defaults #pause
  - rigorous schemas require willingness from the community
  
]

== ... willingness from the community?
#image("cwl/qe_issue.png", height: 100%)

#image("cwl/qe_issue_2.png", width: 100%)

= Building ideas from CWL into `koopmans`
== Building ideas from CWL into `koopmans`
`koopmans` is slowly being refactored into "CWL-inspired" Python

#show raw: it => [
  #set text(size: 0.5em)
  #it
]
#raw(read("process.py"), lang: "python")

== A simple `CommandLineTool`

#raw(read("bin2xml.py"), lang: "python")

== An example composite workflow

#raw(read("kcw_then_w90.py"), lang: "python")
#show raw: it => [
  #set text(size: 2em)
  #it
]

= So what?
== `koopmans` + `AiiDA`

UI practically unchanged:

  `$ koopmans tio2.json` #pause $arrow.r$ `$ koopmans run --engine=aiida tio2.json`

#pause
but executed remotely and in parallel:

#align(center, 
  image("figures/aiida-speed-up.svg", width: 90%)
)

= Outlook
== Workflow-runner-agnostic workflows?
A lot of the pain in `koopmans` + `AiiDA` derives from wanting to have two workflow runners:
- `localhost`  (the original `koopmans` implementation)
- `AiiDA`

#pause
Can we write runner-agnostic workflows? #pause
- yes! CWL the most rigorous way#footnote([but still requires schemas, so not truly general]), but `koopmans` (kind of) achieves this #pause

Do we want to write runner-agnostic workflows? #pause
- probably not... #pause

(_cf._ Do we want to write calculator-agnostic workflows?
- yes! See Common Workflows @Huber2021)

== If not, what should we do?
What do people want? #pause
- quick to write #pause
- understandable #pause
- customisable #pause

What should we do when writing code? #pause
- always have inputs and outputs rigorously defined -- think functionally! #pause
- be modular wherever possible #pause
- be abstract wherever possible #pause
- make it easy for people to tweak and combine workflows #pause
  - (should `AiiDA` be able to read and dump `.cwl` files?) #pause
- for `AiiDA`, continue efforts to simplify

#focus-slide(background-color: black)[
  #set text(font: "edwardian script itc", size: 3em)
  #align(center, [_Fin_])
]


== References

#bibliography("references.bib")
