InputModel = TypeVar('InputModel', bound=BaseModel)
OutputModel = TypeVar('OutputModel', bound=BaseModel)

class Process(ABC, Generic[InputModel, OutputModel]):

    input_model: Type[InputModel]
    output_model: Type[OutputModel]

    def __init__(self, name: str | None = None, **kwargs):
        self.inputs: InputModel = self.input_model(**kwargs)
        self.outputs: OutputModel | None = None
        self.directory: Path | None = None

    def run(self):
        assert self.directory is not None, 'Process directory must be set before running'
        with utils.chdir(self.directory):
            self.dump_inputs()
            self._run()
            assert self.outputs is not None, 'Process outputs must be set when running'
            self.dump_outputs()

    @abstractmethod
    def _run(self):
        ...