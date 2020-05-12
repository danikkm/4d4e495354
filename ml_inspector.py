import coremltools

coreml_model_path = "./my_mnist.mlmodel"

spec = coremltools.utils.load_spec(coreml_model_path)
builder = coremltools.models.neural_network.NeuralNetworkBuilder(spec=spec)
builder.inspect_layers()
builder.inspect_input_features()
neuralnetwork_spec = builder.spec

print neuralnetwork_spec.description.input[0].type.imageType.width
print model.summary()
