class Bin2XMLInput(IOModel):
    binary: File
    model_config = ConfigDict(arbitrary_types_allowed=True)

class Bin2XMLOutput(IOModel):
    xml: File
    model_config = ConfigDict(arbitrary_types_allowed=True)

class Bin2XMLPCommandLineTool(CommandLineTool[Bin2XMLInput, Bin2XMLOutput]):

    input_model = Bin2XMLInput
    output_model = Bin2XMLOutput

    def _pre_run(self):
        super()._pre_run()
        if not self.inputs.binary.exists():
            raise FileNotFoundError(f'`{self.inputs.binary}` does not exist')

        # Link the input binary file to the directory of this process as input.dat
        dst = self / "input.dat"
        dst.symlink_to(self.inputs.binary)

    @property
    def command(self):
        return Command(executable='bin2xml.x', suffix='input.dat output.xml')

    def _set_outputs(self):
        self.outputs = self.output_model(xml=self / "output.xml")
