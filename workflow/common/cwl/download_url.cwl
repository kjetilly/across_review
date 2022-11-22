cwlVersion: v1.2
class: CommandLineTool
baseCommand: ['curl']
arguments:
  - position: 1
    valueFrom: '$(inputs.input_url)/$(inputs.input_file_name)'
  - position: 2
    valueFrom: '--location'
  - position: 3
    valueFrom: '$(inputs.input_file_name)'
    prefix: '--output'
inputs:
  input_url:
    type: string
  input_file_name: 
    type: string
outputs:
  downloaded_file:
    type: File        
    outputBinding:  
      glob: $(inputs.input_file_name)
