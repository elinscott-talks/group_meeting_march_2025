cwlVersion: v1.2
class: Operation

inputs:
   input_file: File
   pseudopotentials:
       type: array
       items:
          type: File
outputs:
   output_file: File

