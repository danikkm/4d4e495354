import coremltools
from keras.models import load_model
from keras import utils
import tensorflow as tf

model = load_model('keras_mnist_model_new.h5')

keras_model = coremltools.converters.keras.convert(model,
                                                   input_names='image (28x28)',
                                                   image_input_names='image (28x28)',
                                                   output_names=['prediction'],
                                                   class_labels=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'])

keras_model.author = 'Keras-team'
keras_model.license = 'nope'
keras_model.short_description = 'Predicts a handwritten digit'

keras_model.save('latest.mlmodel')
