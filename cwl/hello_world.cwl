cwlVersion: v1.2
class: CommandLineTool

inputs:
  message:
    type: string
    default: "Hello World"
    inputBinding:
      position: 1
outputs: []

baseCommand: echo