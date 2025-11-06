from keras.datasets import mnist
import idx2numpy


if __name__ == '__main__':
    (X_train, y_train), (X_test, y_test) = mnist.load_data()
    X_train = X_train / 255.0
    X_test = X_test /255.0

    # Create 5 item image and label files
    idx2numpy.convert_to_file('5-images.idx', X_test[:5])
    idx2numpy.convert_to_file('5-labels.idx', y_test[:5])
