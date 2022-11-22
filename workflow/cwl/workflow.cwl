cwlVersion: v1.2
class: Workflow
inputs:
  dataset_url: string
  dataset_name: string
  input_ensemble_file: string
  input_ensemble_base: string
outputs:
  results:
    type: File[]
    outputSource: ertopmflow/flow_output
steps:
  download:
    run: ../common/cwl/download_url.cwl
    in:
      input_url: dataset_url
      input_file_name: dataset_name
    out: [downloaded_file]
  unzip:
    run: ../common/cwl/unzip.cwl
    in:
      input_file: download/downloaded_file
    out: [unzipped_files]
  ertopmflow:
    run:
      class: CommandLineTool
      baseCommand: ['run_ert_venv.sh']
      requirements:
        InitialWorkDirRequirement:
          listing:          
            - $(inputs.input_files)
      stdout: output_flow.log
      arguments:
         - position: 1
           valueFrom: 'ensemble_experiment'
         - position: 2
           valueFrom: '--verbose'
         - position: 3
           valueFrom: '$(runtime.outdir)/$(inputs.workdir)/$(inputs.input_ensemble_path)'
      inputs:
        workdir:
          type: string
        input_files:
          type: Directory
        input_ensemble_path:
          type: string
      outputs:
        flow_output:
          type: File[]
          outputBinding:  
            glob: '$(runtime.outdir)/$(inputs.workdir)/example/output*'
    in:
      workdir: input_ensemble_base 
      input_files: unzip/unzipped_files
      input_ensemble_path: input_ensemble_file
    out: [flow_output]
