extension Logger<T> on T {
  void logError() {
    print("Error: ${toString()}");
  }

  void logOut() {
    print("Data: ${toString()}");
  }
}
