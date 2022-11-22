cwlVersion: v1.2
class: CommandLineTool
baseCommand: ['unzip']
inputs:
  input_file:
    type: File
    inputBinding:
      position: 0
outputs:
  unzipped_files:
    type: File[] 
    outputBinding:
      glob: "*"
