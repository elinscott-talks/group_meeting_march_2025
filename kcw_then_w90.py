# Read and run the Koopmans workflow
wf = read('si.json')
wf.run()

# Merge the separate occ + emp projections into a set of projections that combines occ + empty
combined_proj_list = [p for block in wf.projections for p in block.projections]
combined_proj_obj = ProjectionBlocks.fromlist([combined_proj_list], ['up'], wf.atoms)

# Find the kcw.x output directory that contains the Hamiltonian to Wannierize
[kcw_ham_calc] = [c for c in wf.calculations if isinstance(c, KoopmansHamCalculator)]
kcw_outdir = kcw_ham_calc.directory / kcw_ham_calc.parameters.outdir

# Construct a Wannierize workflow for the joint occ + empty manifold
wann_wf = WannierizeBlockWorkflow.from_other(wf,
    block=combined_proj_obj[0],
    pw_outdir=kcw_outdir,
    write_tb=True,
    calculate_bands=True)
wann_wf.calculator_parameters['pw2wannier'].prefix = 'kc_kcw'
wann_wf.directory /= '02-joint-wannierize'

# Run the Wannierization
wann_wf.run()
