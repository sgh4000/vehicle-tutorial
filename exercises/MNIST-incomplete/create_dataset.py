from keras.datasets import fashion_mnist
import idx2numpy


if __name__ == '__main__':
    (X_train, y_train), (X_test, y_test) = fashion_mnist.load_data()
    X_train = X_train / 255.0
    X_test = X_test /255.0

    idx2numpy.convert_to_file('/home/mohammad/D2AIR/vehicle-tutorial/exercises/MNIST-incomplete/500-images.idx', X_test[:500])
    idx2numpy.convert_to_file('/home/mohammad/D2AIR/vehicle-tutorial/exercises/MNIST-incomplete/500-labels.idx', y_test[:500])
